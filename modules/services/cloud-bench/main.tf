#----------------------------------------------------------
# Fetch & compute required data
#----------------------------------------------------------

data "aws_caller_identity" "me" {}

data "aws_organizations_organization" "org" {
  count = var.is_organizational ? 1 : 0
}

data "sysdig_secure_trusted_cloud_identity" "trusted_identity" {
  cloud_provider = "aws"
}

locals {
  member_account_ids    = var.is_organizational ? [for a in data.aws_organizations_organization.org[0].non_master_accounts : a.id] : []
  account_ids_to_deploy = var.is_organizational && var.provision_in_management_account ? concat(local.member_account_ids, [data.aws_organizations_organization.org[0].master_account_id]) : local.member_account_ids

  benchmark_task_name   = var.is_organizational ? "Organization: ${data.aws_organizations_organization.org[0].id}" : data.aws_caller_identity.me.account_id
  accounts_scope_clause = var.is_organizational ? "aws.accountId in (\"${join("\", \"", local.account_ids_to_deploy)}\")" : "aws.accountId = \"${data.aws_caller_identity.me.account_id}\""
  regions_scope_clause  = length(var.benchmark_regions) == 0 ? "" : " and aws.region in (\"${join("\", \"", var.benchmark_regions)}\")"
}

#----------------------------------------------------------
# Configure Sysdig Backend
#----------------------------------------------------------

resource "sysdig_secure_cloud_account" "cloud_account" {
  for_each = var.is_organizational ? toset(local.account_ids_to_deploy) : [data.aws_caller_identity.me.account_id]

  account_id     = each.value
  cloud_provider = "aws"
  role_enabled   = "true"
  role_name      = var.name
}

locals {
  external_id = try(
    sysdig_secure_cloud_account.cloud_account[local.account_ids_to_deploy[0]].external_id,
    sysdig_secure_cloud_account.cloud_account[data.aws_caller_identity.me.account_id].external_id,
  )
}

resource "random_integer" "minute" {
  max = 59
  min = 0
}

resource "random_integer" "hour" {
  max = 23
  min = 0
}

resource "sysdig_secure_benchmark_task" "benchmark_task" {
  name     = "Sysdig Secure for Cloud (AWS) - ${local.benchmark_task_name}"
  schedule = "${random_integer.minute.result} ${random_integer.hour.result} * * *"
  schema   = "aws_foundations_bench-1.3.0"
  scope    = "${local.accounts_scope_clause}${local.regions_scope_clause}"

  # Creation of a task requires that the Cloud Account already exists in the backend, and has `role_enabled = true`
  # We only want to create the task once the rust relationship is established, otherwise running the task will fail.
  depends_on = [
    sysdig_secure_cloud_account.cloud_account,
    aws_iam_role_policy_attachment.cloudbench_security_audit, # Depends on cloudbench_role implicitly
  ]
}


#----------------------------------------------------------
# If this is not an Organizational deploy, create role/polices directly
#----------------------------------------------------------

data "aws_iam_policy" "security_audit" {
  arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

data "aws_iam_policy_document" "trust_relationship" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [data.sysdig_secure_trusted_cloud_identity.trusted_identity.identity]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [local.external_id]
    }
  }
}

resource "aws_iam_role" "cloudbench_role" {
  count = var.is_organizational && !var.provision_in_management_account ? 0 : 1

  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.trust_relationship.json
  tags               = var.tags
}


resource "aws_iam_role_policy_attachment" "cloudbench_security_audit" {
  count = var.is_organizational && !var.provision_in_management_account ? 0 : 1

  role       = aws_iam_role.cloudbench_role[0].id
  policy_arn = data.aws_iam_policy.security_audit.arn
}


#----------------------------------------------------------
# If this is an Organizational deploy, use a CloudFormation StackSet
#----------------------------------------------------------

resource "aws_cloudformation_stack_set" "stackset" {
  count = var.is_organizational ? 1 : 0

  name             = var.name
  tags             = var.tags
  permission_model = "SERVICE_MANAGED"
  capabilities     = ["CAPABILITY_NAMED_IAM"]

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }

  template_body = <<TEMPLATE
Resources:
  SysdigCloudBench:
    Type: AWS::IAM::Role
    Properties:
      RoleName: ${var.name}
      AssumeRolePolicyDocument:
        Statement:
          - Effect: Allow
            Principal:
              AWS: [ ${data.sysdig_secure_trusted_cloud_identity.trusted_identity.identity} ]
            Action: [ 'sts:AssumeRole' ]
            Condition:
              StringEquals:
                sts:ExternalId: ${local.external_id}
      ManagedPolicyArns:
        - "arn:aws:iam::aws:policy/SecurityAudit"
TEMPLATE
}

resource "aws_cloudformation_stack_set_instance" "stackset_instance" {
  count = var.is_organizational ? 1 : 0

  region         = var.region
  stack_set_name = aws_cloudformation_stack_set.stackset[0].name
  deployment_targets {
    organizational_unit_ids = [for root in data.aws_organizations_organization.org[0].roots : root.id]
  }
}

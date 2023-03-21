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
  caller_account        = data.aws_caller_identity.me.account_id
  member_account_ids    = var.is_organizational ? [for a in data.aws_organizations_organization.org[0].non_master_accounts : a.id] : []
  account_ids_to_deploy = var.is_organizational && var.provision_caller_account ? concat(local.member_account_ids, [data.aws_organizations_organization.org[0].master_account_id]) : local.member_account_ids
}

#----------------------------------------------------------
# Configure Sysdig Backend
#----------------------------------------------------------

resource "sysdig_secure_cloud_account" "cloud_account" {
  for_each = var.is_organizational ? toset(local.account_ids_to_deploy) : [local.caller_account]

  account_id     = each.value
  cloud_provider = "aws"
  role_enabled   = "true"
  role_name      = var.name

  lifecycle {
    ignore_changes = [alias]
  }
}

locals {
  external_id = try(
    sysdig_secure_cloud_account.cloud_account[local.account_ids_to_deploy[0]].external_id,
    sysdig_secure_cloud_account.cloud_account[local.caller_account].external_id,
  )
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
  count = var.is_organizational && !var.provision_caller_account ? 0 : 1

  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.trust_relationship.json
  tags               = var.tags
}


resource "aws_iam_role_policy_attachment" "cloudbench_security_audit" {
  count = var.is_organizational && !var.provision_caller_account ? 0 : 1

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


  lifecycle {
    ignore_changes = [administration_role_arn]
  }
}

resource "aws_cloudformation_stack_set_instance" "stackset_instance" {
  count = var.is_organizational ? 1 : 0

  region         = var.region
  stack_set_name = aws_cloudformation_stack_set.stackset[0].name
  deployment_targets {
    organizational_unit_ids = [for root in data.aws_organizations_organization.org[0].roots : root.id]
  }
  operation_preferences {
    failure_tolerance_count = 100
    max_concurrent_count    = 5
  }
}

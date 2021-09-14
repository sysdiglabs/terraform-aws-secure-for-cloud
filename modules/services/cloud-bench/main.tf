#
# Sysdig Secure cloud provisioning
#
resource "sysdig_secure_cloud_account" "cloud_account" {
  account_id     = var.account_id
  cloud_provider = "aws"
  role_enabled   = "true"
  role_name      = var.role_name
}

data "sysdig_secure_trusted_cloud_identity" "trusted_identity" {
  cloud_provider = "aws"
}

locals {
  regions_scope_clause = length(var.regions) == 0 ? "" : " and aws.region in (\"${join("\", \"", var.regions)}\")"
}

resource "sysdig_secure_benchmark_task" "benchmark_task" {
  name     = "Sysdig Secure for Cloud (AWS) - ${var.account_id}"
  schedule = "0 6 * * *"
  schema   = "aws_foundations_bench-1.3.0"
  scope    = "aws.accountId = \"${var.account_id}\"${local.regions_scope_clause}"

  # Creation of a task requires that the Cloud Account already exists in the backend, and has `role_enabled = true`
  depends_on = [sysdig_secure_cloud_account.cloud_account]
}

#
# aws role provisioning
#

resource "aws_iam_role" "cloudbench_role" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.trust_relationship.json
  tags               = var.tags
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
      values   = [sysdig_secure_cloud_account.cloud_account.external_id]
    }
  }
}



resource "aws_iam_role_policy_attachment" "cloudbench_security_audit" {
  role       = aws_iam_role.cloudbench_role.id
  policy_arn = data.aws_iam_policy.security_audit.arn
}

data "aws_iam_policy" "security_audit" {
  arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

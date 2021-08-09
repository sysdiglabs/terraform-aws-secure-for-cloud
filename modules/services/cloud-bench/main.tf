resource "sysdig_secure_cloud_account" "cloud_account" {
  account_id = var.account_id
  cloud_provider = "aws"
  role_enabled = "true"
}

resource "aws_iam_role" "cloudbench_role" {
  name = "SysdigCloudBenchRole"
  assume_role_policy = data.aws_iam_policy_document.trust_relationship.json
  tags = var.tags
}

data "sysdig_secure_trusted_cloud_user" "trusted_sysdig_role" {
  cloud_provider = "aws"
}

data "aws_iam_policy_document" "trust_relationship" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"
      identifiers = [data.sysdig_secure_trusted_cloud_user.trusted_sysdig_role.arn]
    }
    condition {
      test = "StringEquals"
      variable = "sts:ExternalId"
      values = [sysdig_secure_cloud_account.cloud_account.external_id]
    }
  }
}

resource "aws_iam_role_policy_attachment" "cloudbench_security_audit" {
  role = aws_iam_role.cloudbench_role.id
  policy_arn = data.aws_iam_policy.SecurityAudit.arn
}

data "aws_iam_policy" "SecurityAudit" {
  arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

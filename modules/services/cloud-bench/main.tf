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

data "sysdig_cloud_bench_user" "trusted_sysdig_role" {
  sysdig_secure_endpoint = var.sysdig_secure_endpoint

  // TODO this should come from the provider based on the secure URL.
  arn = "arn:aws:iam::059797578166:user/noah.kraemer"
}

data "aws_iam_policy_document" "trust_relationship" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"
      identifiers = [data.sysdig_cloud_bench_user.trusted_sysdig_role.arn]
    }
    condition {
      test = "StringEquals"
      variable = "sts:ExternalId"
      values = [sysdig_secure_cloud_account.cloud_account.external_id]
    }
  }
}

resource "aws_iam_role_policy" "cloudbench_permissions" {
  name = "SysdigCloudBenchPolicy"
  role = aws_iam_role.cloudbench_role.id
  policy = data.aws_iam_policy_document.permissions.json
}

data "aws_iam_policy_document" "permissions" {
  statement {
    effect = "Allow"
    actions = [
      "access-analyzer:List*",
      "acm:List*",
      "cloudtrail:DescribeTrails",
      "cloudtrail:Get*",
      "cloudwatch:Describe*",
      "cloudwatch:PutMetricData",
      "config:Describe*",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:Describe*",
      "elasticloadbalancing:DescribeLoadBalancers",
      "events:PutRule",
      "events:PutTargets",
      "iam:DeleteAccessKey",
      "iam:GenerateCredentialReport",
      "iam:Get*",
      "iam:List*",
      "iam:UpdateAccessKey",
      "lambda:AddPermission",
      "lambda:CreateAlias",
      "lambda:CreateEventSourceMapping",
      "lambda:CreateFunction",
      "lambda:DeleteAlias",
      "lambda:DeleteEventSourceMapping",
      "lambda:DeleteFunction",
      "lambda:DeleteFunctionConcurrency",
      "lambda:InvokeFunction",
      "lambda:PutFunctionConcurrency",
      "lambda:RemovePermission",
      "lambda:TagResource",
      "lambda:UntagResource",
      "lambda:UpdateAlias",
      "lambda:UpdateEventSourceMapping",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:Describe*",
      "kms:ListAliases",
      "kms:ListKeys",
      "kms:DescribeKey",
      "kms:GetKeyRotationStatus",
      "s3:Get*",
      "s3:Head*",
      "s3:List*",
      "s3:Put*",
      "sns:ListSubscriptionsByTopic",
      "tag:GetResources"
    ]
    resources = ["*"]
  }
}

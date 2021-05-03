data "aws_iam_policy_document" "cloudconnector_assumerole" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${var.main_account_id}:root"]
      type        = "AWS"
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalARN"
      values   = ["arn:aws:iam::${var.main_account_id}:role/${var.naming_prefix}-CloudConnectorTaskRole"]
    }
  }
}

data "aws_iam_policy_document" "cloudtrail_ingestor" {
  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Put*",
      "s3:Head*",
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch",
      "sqs:ReceiveMessage",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "cloudconnector" {
  count = var.cloudconnector_deploy ? 1 : 0

  name = "${var.naming_prefix}-CloudConnectorRole"

  assume_role_policy = data.aws_iam_policy_document.cloudconnector_assumerole.json
  path               = "/"

  inline_policy {
    name   = "CloudTrailIngestor"
    policy = data.aws_iam_policy_document.cloudtrail_ingestor.json
  }
}

data "aws_iam_policy_document" "cloudscanning_assumerole" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${var.main_account_id}:root"]
      type        = "AWS"
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalARN"
      values   = ["arn:aws:iam::${var.main_account_id}:role/${var.naming_prefix}-CloudScanningTaskRole"]
    }
  }
}

data "aws_iam_policy_document" "task_definition_reader" {
  statement {
    effect = "Allow"
    actions = [
      "ecs:DescribeTaskDefinition",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "secrets_reader" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "secretsmanager:GetSecretValue",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecr_reader" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:ListTagsForResource",
      "ecr:DescribeImageScanFindings",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "cloudscanning" {
  count = var.cloudscanning_deploy ? 1 : 0

  name = "${var.naming_prefix}-CloudScanningRole"

  assume_role_policy = data.aws_iam_policy_document.cloudscanning_assumerole.json
  path               = "/"

  inline_policy {
    name   = "CloudTrailIngestor"
    policy = data.aws_iam_policy_document.cloudtrail_ingestor.json
  }

  inline_policy {
    name   = "TaskDefinitionReader"
    policy = data.aws_iam_policy_document.task_definition_reader.json
  }

  inline_policy {
    name   = "SecretsReader"
    policy = data.aws_iam_policy_document.secrets_reader.json
  }

  inline_policy {
    name   = "ECRReader"
    policy = data.aws_iam_policy_document.ecr_reader.json
  }

}

data "aws_iam_policy_document" "cloudbench_assumerole" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${var.main_account_id}:root"]
      type        = "AWS"
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalARN"
      values   = ["arn:aws:iam::${var.main_account_id}:role/${var.naming_prefix}-CloudBenchTaskRole"]
    }
  }
}

data "aws_iam_policy_document" "cloudcustodian_executor" {
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

resource "aws_iam_role" "cloudbench" {
  count = var.cloudbench_deploy ? 1 : 0

  name = "${var.naming_prefix}-CloudBenchRole"

  assume_role_policy = data.aws_iam_policy_document.cloudbench_assumerole.json
  path               = "/"

  inline_policy {
    name   = "CloudCustodianExecutor"
    policy = data.aws_iam_policy_document.cloudcustodian_executor.json
  }
}

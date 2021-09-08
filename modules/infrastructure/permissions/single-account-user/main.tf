resource "aws_iam_user" "this" {
  name          = var.name
  force_destroy = true
  tags          = var.tags
}

resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name
}

resource "aws_iam_user_policy" "this" {
  name   = var.name
  user   = aws_iam_user.this.name
  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {

  # --------------------
  # task statements
  # --------------------
  statement {
    sid    = "AllowReadCloudtrailS3"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*"
      # TODO. scanning, only when used with ECS mode
      #      "s3:Put*",
      #      "s3:Head",
    ]
    resources = [
      var.cloudtrail_s3_bucket_arn,
      "${var.cloudtrail_s3_bucket_arn}/AWSLogs/*"
    ]
  }

  statement {
    sid    = "AllowReadWriteCloudtrailSubscribedSQS"
    effect = "Allow"
    actions = [
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch",
      "sqs:ReceiveMessage"
    ]
    resources = var.cloudtrail_sns_subscribed_sqs_arns
  }


  statement {
    sid    = "AllowReadSecurityHub"
    effect = "Allow"
    actions = [
      "securityhub:GetFindings",
      "securityhub:BatchImportFindings",
    ]
    resources = ["arn:aws:securityhub:${data.aws_region.current.name}::product/sysdig/sysdig-cloud-connector"] # TODO. make an input-var out of this
  }


  statement {
    sid    = "AllowCloudwatchLogManagement"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
      "logs:PutLogEvents",
    ]
    resources = ["*"] # TODO. make an input-var out of this. make it more specific "arn:aws:logs:eu-central-1:522353683035:log-group:test:*"
  }

  # -----------------------------
  # task statements/cloud-scanner
  # -----------------------------

  statement {
    sid    = "AllowScanningCodeBuildStartBuild"
    effect = "Allow"
    actions = [
      "codebuild:StartBuild"
    ]
    resources = [var.scanning_build_project_arn]
  }

  statement {
    sid    = "AllowScanningECRRead"
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
      "ecr:DescribeImageScanFindings"
    ]
    resources = ["*"] # TODO. make an input-var out of this, so user can pin it to its own ECR ARN's
  }

  statement {
    sid    = "AllowScanningDescribeECSTask"
    effect = "Allow"
    actions = [
      "ecs:DescribeTaskDefinition"
    ]
    resources = ["*"] # TODO
  }

  statement {
    sid    = "AllowScanningTo" # TODO
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "secretsmanager:GetSecretValue"
    ]
    resources = ["*"] # TODO
  }

  # --------------------
  # execution statements
  # --------------------
  statement {
    sid       = "AllowSSMGetParameter"
    effect    = "Allow"
    actions   = ["ssm:GetParameters"]
    resources = [data.aws_ssm_parameter.sysdig_secure_api_token.arn]
    #    resources = ["*"]
  }
}

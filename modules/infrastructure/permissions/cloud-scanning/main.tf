resource "aws_iam_user_policy" "cloud_scanner" {
  name   = "${var.name}-cs"
  user   = data.aws_iam_user.this.user_name
  policy = data.aws_iam_policy_document.cloud_scanner.json
}

data "aws_iam_policy_document" "cloud_scanner" {

  statement {
    sid    = "AllowReadWriteCloudtrailSubscribedSQS"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch"
    ]
    resources = [var.cloudtrail_subscribed_sqs_arn]
  }

  statement {
    sid    = "AllowScanningCodeBuildStartBuild"
    effect = "Allow"
    actions = [
      "codebuild:StartBuild"
    ]
    resources = [var.scanning_codebuild_project_arn]
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
}

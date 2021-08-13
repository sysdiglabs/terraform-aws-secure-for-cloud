data "aws_region" "current" {}
data "aws_caller_identity" "me" {}
data "aws_partition" "current_partition" {}
data "aws_ssm_parameter" "sysdig_secure_api_token" {
  name = var.secure_api_token_secret_name
}

resource "aws_iam_role" "service" {
  name               = "${var.name}-ECRScanningRole"
  assume_role_policy = data.aws_iam_policy_document.service_assume_role.json
  path               = "/"
  tags               = var.tags
}

data "aws_iam_policy_document" "service_assume_role" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["codebuild.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "logs_publisher" {
  name   = "LogsPublisher"
  role   = aws_iam_role.service.id
  policy = data.aws_iam_policy_document.logs_publisher.json
}

data "aws_iam_policy_document" "logs_publisher" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:${data.aws_partition.current_partition.id}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.me.account_id}:log-group:${aws_codebuild_project.build-project.logs_config[0].cloudwatch_logs[0].group_name}",
      "arn:${data.aws_partition.current_partition.id}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.me.account_id}:log-group:${aws_codebuild_project.build-project.logs_config[0].cloudwatch_logs[0].group_name}:*"
    ]
  }
}

resource "aws_iam_role_policy" "read_parameters" {
  name   = "ReadParameters"
  policy = data.aws_iam_policy_document.task_read_parameters.json
  role   = aws_iam_role.service.id
}
data "aws_iam_policy_document" "task_read_parameters" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters"
    ]
    resources = [data.aws_ssm_parameter.sysdig_secure_api_token.arn]
  }
}
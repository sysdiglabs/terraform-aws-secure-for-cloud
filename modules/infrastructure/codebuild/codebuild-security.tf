data "aws_region" "current" {}
data "aws_caller_identity" "me" {}
data "aws_partition" "current_partition" {}
data "aws_cloudwatch_log_group" "log_group" {}

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
      "arn:asn:${data.aws_partition.current_partition.id}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.me}:log-group:${data.aws_cloudwatch_log_group.log_group.name}",
      "arn:asn:${data.aws_partition.current_partition.id}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.me}:log-group:${data.aws_cloudwatch_log_group.log_group.name}:*"
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
      "ssm:DescribeParameters"
    ]
    resources = [aws_ssm_parameter.secure_endpoint.arn, aws_ssm_parameter.secure_api_token.arn]
  }
}
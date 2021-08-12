data "aws_region" "current" {}
data "aws_caller_identity" "me" {}
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
      aws_cloudwatch_log_group.log.arn,
      "${aws_cloudwatch_log_group.log.arn}:*"
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
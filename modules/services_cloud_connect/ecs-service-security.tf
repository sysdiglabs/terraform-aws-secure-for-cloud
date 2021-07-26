


#---------------------------------
# task role
#---------------------------------
resource "aws_iam_role" "task" {
  name               = "${var.name}-ECSTaskRole"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role.json
  path               = "/"
  tags               = var.tags
}
data "aws_iam_policy_document" "task_assume_role" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "task" {
  name   = "${var.name}-TaskPolicy"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.iam_role_task_policy.json
}
data "aws_iam_policy_document" "iam_role_task_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*", // FIXME. refine only for Get and List
      "sts:AssumeRole",

      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
      "logs:PutLogEvents",

      // FIXME. this should be done over the specific resource
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch",
      "sqs:ReceiveMessage"
    ]
    // TODO Add the only resources needed for this policy to work with
    resources = ["*"] // TODO specific
  }

  statement {
    sid    = "AllowSecurityHub"
    effect = "Allow"
    actions = [
      "securityhub:GetFindings",
      "securityhub:BatchImportFindings",
    ]
    resources = ["arn:aws:securityhub:${data.aws_region.current.name}::product/sysdig/sysdig-cloud-connector"]
  }
}

resource "aws_iam_role_policy" "enable_assume_cloudvision_role" {
  name   = "${var.name}-EnableCloudvisionRole"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.enable_assume_cloudvision_role.json
}
data "aws_iam_policy_document" "enable_assume_cloudvision_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [var.services_assume_role_arn]
  }
}


#---------------------------------
# execution role
# This role is required by tasks to pull container images and publish container logs to Amazon CloudWatch on your behalf.
#---------------------------------
resource "aws_iam_role" "execution" {
  name               = "${var.name}-ECSTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.execution_assume_role.json
  path               = "/"
  tags               = var.tags
}
data "aws_iam_policy_document" "execution_assume_role" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role_policy" "task_read_parameters" {
  name   = "${var.name}-TaskReadParameters"
  policy = data.aws_iam_policy_document.task_read_parameters.json
  role   = aws_iam_role.execution.id
}
data "aws_iam_policy_document" "task_read_parameters" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters"]
    resources = [data.aws_ssm_parameter.endpoint.arn, data.aws_ssm_parameter.api_token.arn]
  }
}


resource "aws_iam_role_policy" "execution" {
  name   = "${var.name}-ExecutionRolePolicy"
  policy = data.aws_iam_policy_document.execution.json
  role   = aws_iam_role.execution.id
}
data "aws_iam_policy_document" "execution" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

locals {
  ecs_task_role_id  = var.organizational_setup.is_organizational ? data.aws_iam_role.task_inherited[0].id : aws_iam_role.task[0].id
  ecs_task_role_arn = var.organizational_setup.is_organizational ? data.aws_iam_role.task_inherited[0].arn : aws_iam_role.task[0].arn
}

#---------------------------------
# task role
# notes
# - duplicated in /examples/organizational/utils.tf, where root lvl role is created, to avoid cyclic dependencies
#---------------------------------
data "aws_iam_role" "task_inherited" {
  count = var.organizational_setup.is_organizational ? 1 : 0
  name  = var.organizational_setup.connector_ecs_task_role_name
}
resource "aws_iam_role" "task" {
  count              = var.organizational_setup.is_organizational ? 0 : 1
  name               = var.organizational_setup.connector_ecs_task_role_name
  assume_role_policy = data.aws_iam_policy_document.task_assume_role[0].json
  path               = "/"
  tags               = var.tags
}
data "aws_iam_policy_document" "task_assume_role" {
  count = var.organizational_setup.is_organizational ? 0 : 1
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
  role   = local.ecs_task_role_id
  policy = data.aws_iam_policy_document.iam_role_task_policy.json
}
data "aws_iam_policy_document" "iam_role_task_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*", # FIXME. refine only for Get and List
      "sts:AssumeRole",

      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
      "logs:PutLogEvents",

      # FIXME. this should be done over the specific resource
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch",
      "sqs:ReceiveMessage"
    ]
    resources = ["*"] # FIXME. make more specific?
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
    resources = [aws_ssm_parameter.secure_endpoint.arn, aws_ssm_parameter.secure_api_token.arn]
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

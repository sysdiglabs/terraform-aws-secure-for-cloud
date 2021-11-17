locals {
  ecs_task_role_id          = var.is_organizational ? data.aws_iam_role.task_inherited[0].id : aws_iam_role.task[0].id
  ecs_task_role_arn         = var.is_organizational ? data.aws_iam_role.task_inherited[0].arn : aws_iam_role.task[0].arn
  ecs_task_role_name_suffix = var.is_organizational ? var.organizational_config.connector_ecs_task_role_name : var.connector_ecs_task_role_name
}

data "aws_ssm_parameter" "sysdig_secure_api_token" {
  name = var.secure_api_token_secret_name
}

#---------------------------------
# task role
# notes
# - duplicated in /examples/organizational/credentials.tf, where root lvl role is created, to avoid cyclic dependencies
#---------------------------------
data "aws_iam_role" "task_inherited" {
  count = var.is_organizational ? 1 : 0
  name  = var.organizational_config.connector_ecs_task_role_name
}

resource "aws_iam_role" "task" {
  count              = var.is_organizational ? 0 : 1
  name               = "${var.name}-${local.ecs_task_role_name_suffix}"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role[0].json
  path               = "/"
  tags               = var.tags
}

data "aws_iam_policy_document" "task_assume_role" {
  count = var.is_organizational ? 0 : 1
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
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch",
      "sqs:ReceiveMessage"
    ]
    resources = [module.cloud_connector_sqs.cloudtrail_sns_subscribed_sqs_arn]
  }
}

resource "aws_iam_role_policy" "trigger_scan" {
  name   = "${var.name}-TriggerScan"
  role   = local.ecs_task_role_id
  policy = data.aws_iam_policy_document.trigger_scan.json
}
data "aws_iam_policy_document" "trigger_scan" {
  statement {
    effect = "Allow"
    actions = [
      "codebuild:StartBuild"
    ]
    resources = [var.build_project_arn]
  }
}

resource "aws_iam_role_policy" "task_definition_reader" {
  name   = "TaskDefinitionReader"
  role   = local.ecs_task_role_id
  policy = data.aws_iam_policy_document.task_definition_reader.json
}
data "aws_iam_policy_document" "task_definition_reader" {
  statement {
    effect = "Allow"
    actions = [
      "ecs:DescribeTaskDefinition"
    ]
    resources = ["*"]
  }
}


resource "aws_iam_role_policy" "secrets_reader" {
  name   = "SecretsReader"
  role   = local.ecs_task_role_id
  policy = data.aws_iam_policy_document.secrets_reader.json
}

data "aws_iam_policy_document" "secrets_reader" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "secretsmanager:GetSecretValue"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecr_reader" {
  name   = "ECRReader"
  role   = local.ecs_task_role_id
  policy = data.aws_iam_policy_document.ecr_reader.json
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
      "ecr:DescribeImageScanFindings"
    ]
    resources = ["*"]
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
    resources = [data.aws_ssm_parameter.sysdig_secure_api_token.arn]
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

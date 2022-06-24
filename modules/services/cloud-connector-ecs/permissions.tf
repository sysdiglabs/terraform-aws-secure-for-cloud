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
    # resources = [var.cloudtrail_s3_arn # would need this as param]
  }
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    resources = ["*"]
    #    resources = [var.connector_ecs_task_role_name]
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

  dynamic statement {
    for_each = var.s3_kms_key_arn == "" ? toset([]) : toset([1])
    content{
      effect = "Allow"
      actions = [
        "kms:Decrypt"
      ]
      resources = [var.s3_kms_key_arn]
    }
  }
}

#
# scan images
#
resource "aws_iam_role_policy" "trigger_scan" {
  count  = local.deploy_scanning_infra ? 1 : 0
  name   = "${var.name}-TriggerScan"
  role   = local.ecs_task_role_id
  policy = data.aws_iam_policy_document.trigger_scan[0].json
}
data "aws_iam_policy_document" "trigger_scan" {
  count = local.deploy_scanning_infra ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "codebuild:StartBuild"
    ]
    resources = [var.build_project_arn]
  }
}

# image scanning - ecs
resource "aws_iam_role_policy" "task_definition_reader" {
  count  = var.deploy_image_scanning_ecs ? 1 : 0
  name   = "TaskDefinitionReader"
  role   = local.ecs_task_role_id
  policy = data.aws_iam_policy_document.task_definition_reader[0].json
}
data "aws_iam_policy_document" "task_definition_reader" {
  count = var.deploy_image_scanning_ecs ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "ecs:DescribeTaskDefinition"
    ]
    resources = ["*"]
    #    resources = var.is_organizational?["arn:aws:ecs:*:*:cluster/*"]:["arn:aws:ecs:*:${data.aws_caller_identity.me.account_id}:cluster/${var.ecs_cluster_name}"]
  }
}

# image scanning - ecr
resource "aws_iam_role_policy" "ecr_reader" {
  count  = var.deploy_image_scanning_ecr ? 1 : 0
  name   = "ECRReader"
  role   = local.ecs_task_role_id
  policy = data.aws_iam_policy_document.ecr_reader[0].json
}

data "aws_iam_policy_document" "ecr_reader" {
  count = var.deploy_image_scanning_ecr ? 1 : 0
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
    # resources = var.is_organizational ? ["arn:aws:ecr:*:*:repository/*", "arn:aws:ecr-public::*:repository/*", "arn:aws:ecr-public::*:registry/*"] : ["arn:aws:ecr-public::${data.aws_caller_identity.me.account_id}:repository/*", "arn:aws:ecr-public::${data.aws_caller_identity.me.account_id}:repository/*", "arn:aws:ecr-public::${data.aws_caller_identity.me.account_id}:registry/*"]
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

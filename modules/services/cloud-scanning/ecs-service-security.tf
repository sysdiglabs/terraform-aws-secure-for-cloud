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
  name   = "${var.name}-TaskRolePolicy"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.iam_role_task_role_policy.json
}
data "aws_iam_policy_document" "iam_role_task_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:Get",
      "s3:List",
      "s3:Put",
      "s3:Head",

      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch",
      "sqs:ReceiveMessage"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "trigger_scan" {
  name   = "${var.name}-TriggerScan"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.trigger_scan.json
}
data "aws_iam_policy_document" "trigger_scan" {
  statement {
    effect = "Allow"
    actions = [
      "codebuild:StartBuild"
    ]
    resources = ["arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.me.account_id}:project/${var.BuildProject}"]
  }
}

resource "aws_iam_role_policy" "task_definition_reader" {
  name   = "TaskDefinitionReader"
  role   = aws_iam_role.task.id
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
  role   = aws_iam_role.task.id
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
  role   = aws_iam_role.task.id
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

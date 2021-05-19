locals {
  single_account              = length(var.accounts_and_regions) == 0
  queue_url                   = local.single_account ? "https://sqs.${data.aws_region.current.name}.amazonaws.com/${data.aws_caller_identity.current.account_id}/${var.naming_prefix}-CloudScanning" : ""
  accounts_and_regions_string = join(",", [for a in var.accounts_and_regions : "${a.account_id}:${a.region}"])
  account_role                = local.single_account ? "" : "${var.naming_prefix}-CloudScanningRole"
  queue_name                  = local.single_account ? "" : "${var.naming_prefix}-CloudScanning"
  task_env_vars = concat([
    {
      name  = "VERIFY_SSL"
      value = tostring(var.verify_ssl)
    },
    {
      name  = "SQS_QUEUE_INTERVAL"
      value = "30s"
    },
    {
      name  = "CODEBUILD_PROJECT"
      value = module.scanning_codebuild.project_id
    },
    {
      name  = "ECR_DEPLOYED"
      value = tostring(var.deploy_ecr)
    },
    {
      name  = "ECS_DEPLOYED"
      value = tostring(var.deploy_ecs)
    },
    {
      name  = "TELEMETRY_DEPLOYMENT_METHOD"
      value = "cft"
    },
    {
      name  = "SQS_QUEUE_URL"
      value = local.queue_url
    },
    {
      name  = "SQS_QUEUE_NAME"
      value = local.queue_name
    },
    {
      name  = "ACCOUNTS_AND_REGIONS"
      value = local.accounts_and_regions_string
    },
    {
      name  = "ACCOUNT_ROLE"
      value = local.account_role
    },
    ], flatten([for env_key, env_value in var.extra_env_vars : [{
      name  = env_key,
      value = env_value
    }]])
  )
}

data "aws_ssm_parameter" "endpoint" {
  name = var.ssm_endpoint
}

data "aws_ssm_parameter" "api_token" {
  name = var.ssm_token
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

module "scanning_codebuild" {
  source        = "../cloudscanning-codebuild"
  ssm_endpoint  = var.ssm_endpoint
  ssm_token     = var.ssm_token
  verify_ssl    = var.verify_ssl
  naming_prefix = var.naming_prefix
}

resource "aws_cloudwatch_log_group" "log" {
  name_prefix       = "${var.naming_prefix}-CloudScanning"
  retention_in_days = var.log_retention
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

data "aws_iam_policy_document" "code_build_scan_executor" {
  statement {
    effect = "Allow"
    actions = [
      "codebuild:StartBuild",
    ]
    resources = [module.scanning_codebuild.project_id]
  }
}

data "aws_iam_policy_document" "cloudtrail_ingestor" {

  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Put*",
      "s3:Head*",
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch",
      "sqs:ReceiveMessage",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "task_definition_reader" {
  statement {
    effect = "Allow"
    actions = [
      "ecs:DescribeTaskDefinition",
    ]
    resources = ["*"]
  }
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

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    resources = ["arn:aws:iam::*:role/${var.naming_prefix}-CloudScanningRole"]
  }
}


resource "aws_iam_role" "task" {
  name               = "${var.naming_prefix}-CloudScanningTaskRole"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role.json
  path               = "/"

  inline_policy {
    name   = "CodeBuildScanExecutor"
    policy = data.aws_iam_policy_document.code_build_scan_executor.json
  }

  dynamic "inline_policy" {
    for_each = local.single_account ? [1] : []
    content {
      name   = "CloudTrailIngestor"
      policy = data.aws_iam_policy_document.cloudtrail_ingestor.json
    }
  }

  dynamic "inline_policy" {
    for_each = local.single_account ? [1] : []
    content {
      name   = "TaskDefinitionReader"
      policy = data.aws_iam_policy_document.task_definition_reader.json
    }
  }

  dynamic "inline_policy" {
    for_each = local.single_account ? [1] : []
    content {
      name   = "SecretsReader"
      policy = data.aws_iam_policy_document.secrets_reader.json
    }
  }

  dynamic "inline_policy" {
    for_each = local.single_account ? [1] : []
    content {
      name   = "ECRReader"
      policy = data.aws_iam_policy_document.ecr_reader.json
    }
  }

  dynamic "inline_policy" {
    for_each = local.single_account ? [] : [1]
    content {
      name   = "AssumeRole"
      policy = data.aws_iam_policy_document.assume_role.json
    }
  }

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

data "aws_iam_policy_document" "execution_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "task_read_parameters" {
  statement {
    effect  = "Allow"
    actions = ["ssm:GetParameters"]
    resources = [
      data.aws_ssm_parameter.endpoint.arn,
      data.aws_ssm_parameter.api_token.arn
    ]
  }
}

resource "aws_iam_role" "execution" {
  name               = "${var.naming_prefix}-CloudScanningExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.execution_assume_role.json
  path               = "/"

  inline_policy {
    name   = "ExecutionRolePolicy"
    policy = data.aws_iam_policy_document.execution_role_policy.json
  }

  inline_policy {
    name   = "TaskReadParameters"
    policy = data.aws_iam_policy_document.task_read_parameters.json
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  requires_compatibilities = ["FARGATE"]
  family                   = "${var.naming_prefix}-cloud_scanning"
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.task.arn
  execution_role_arn       = aws_iam_role.execution.arn
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      environment = local.task_env_vars
      secrets = [
        {
          name      = "SECURE_URL"
          valueFrom = data.aws_ssm_parameter.endpoint.arn
        },
        {
          name      = "SECURE_API_TOKEN"
          valueFrom = data.aws_ssm_parameter.api_token.arn
        }
      ]
      name      = "CloudScanning"
      image     = var.image
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.log.id
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }
    },
  ])
}

resource "aws_security_group" "sg" {
  vpc_id      = var.vpc
  name_prefix = "${var.naming_prefix}-CloudScanning"

  description = "CloudScanning workload Security Group"
  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" : "${var.naming_prefix}-CloudScanning"
  }
}

data "aws_ecs_cluster" "ecs" {
  cluster_name = var.ecs_cluster
}

resource "aws_ecs_service" "service" {
  name          = "${var.naming_prefix}-CloudScanning"
  cluster       = data.aws_ecs_cluster.ecs.id
  desired_count = 1
  launch_type   = "FARGATE"
  network_configuration {
    subnets         = var.subnets
    security_groups = [aws_security_group.sg.id]
  }
  task_definition = aws_ecs_task_definition.task_definition.arn
}

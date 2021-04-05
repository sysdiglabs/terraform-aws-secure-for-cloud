locals {
  task_env_vars = concat([
    {
      name  = "VERIFY_SSL"
      value = tostring(var.verify_ssl)
    },
    {
      name  = "SQS_QUEUE_URL"
      value = aws_sqs_queue.sqs.id
    },
    {
      name  = "SQS_QUEUE_INTERVAL"
      value = "30s"
    },
    {
      name  = "CODEBUILD_PROJECT"
      value = var.codebuild_project
    },
    {
      name  = "ECR_DEPLOYED"
      value = tostring(var.deploy_ecr)
    },
    {
      name  = "ECS_DEPLOYED"
      value = tostring(var.deploy_ecs)
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

resource "aws_sqs_queue" "sqs" {
}

data "aws_iam_policy_document" "sqs_queue" {
  statement {
    sid       = "Allow CloudTrail to send messages"
    effect    = "Allow"
    principals {
      identifiers = ["sns.amazonaws.com"]
      type        = "Service"
    }
    actions   = [
      "sqs:SendMessage",
      "sqs:SendMessageBatch"
    ]
    resources = [aws_sqs_queue.sqs.arn]
    condition {
      test     = "ArnEquals"
      values   = var.sns_topic_arns
      variable = "aws:SourceArn"
    }
  }
}

resource "aws_sqs_queue_policy" "sqs" {
  policy    = data.aws_iam_policy_document.sqs_queue.json
  queue_url = aws_sqs_queue.sqs.id
}

resource "aws_sns_topic_subscription" "sns" {
  for_each  = toset(var.sns_topic_arns)
  endpoint  = aws_sqs_queue.sqs.arn
  protocol  = "sqs"
  topic_arn = each.value
}

resource "aws_cloudwatch_log_group" "log" {
  name_prefix       = var.name
  retention_in_days = var.log_retention
}

data "aws_iam_policy_document" "task_assume_role" {
  statement {
    effect  = "Allow"
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "task" {
  assume_role_policy = data.aws_iam_policy_document.task_assume_role.json
  path               = "/"
}

data "aws_iam_policy_document" "iam_role_task_policy" {
  statement {
    effect    = "Allow"
    actions   = [// TODO Do not add so much permissions
      "s3:GetObject",
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch",
      "sqs:ReceiveMessage",
    ]
    // TODO Add the only resources needed for this policy to work with
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "task" {
  policy = data.aws_iam_policy_document.iam_role_task_policy.json
  role   = aws_iam_role.task.id
}

data "aws_iam_policy_document" "task_definition_reader" {
  statement {
    effect    = "Allow"
    actions   = [
      "ecs:DescribeTaskDefinition",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "task_definition_reader" {
  policy = data.aws_iam_policy_document.task_definition_reader.json
  role   = aws_iam_role.task.id
}

data "aws_iam_policy_document" "trigger_scan" {
  statement {
    effect    = "Allow"
    actions   = [
      "codebuild:StartBuild",
    ]
    resources = [var.codebuild_project]
  }
}

resource "aws_iam_role_policy" "trigger_scan" {
  policy = data.aws_iam_policy_document.trigger_scan.json
  role   = aws_iam_role.task.id
}

data "aws_iam_policy_document" "secrets_reader" {
  statement {
    effect    = "Allow"
    actions   = [
      "kms:Decrypt",
      "secretsmanager:GetSecretValue"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "secrets_reader" {
  policy = data.aws_iam_policy_document.secrets_reader.json
  role   = aws_iam_role.task.id
}

data "aws_iam_policy_document" "ecr_reader" {
  statement {
    effect    = "Allow"
    actions   = [// TODO Do not add so much permissions
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

resource "aws_iam_role_policy" "ecr_reader" {
  policy = data.aws_iam_policy_document.ecr_reader.json
  role   = aws_iam_role.task.id
}

data "aws_iam_policy_document" "execution_assume_role" {
  statement {
    effect  = "Allow"
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "execution" {
  assume_role_policy = data.aws_iam_policy_document.execution_assume_role.json
  path               = "/"
}

data "aws_iam_policy_document" "execution" {
  statement {
    effect    = "Allow"
    actions   = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "execution" {
  name   = "${var.name}-ExecutionRolePolicy"
  policy = data.aws_iam_policy_document.execution.json
  role   = aws_iam_role.execution.id
}


data "aws_iam_policy_document" "task_read_parameters" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters"]
    resources = [data.aws_ssm_parameter.endpoint.arn, data.aws_ssm_parameter.api_token.arn]
  }
}

resource "aws_iam_role_policy" "task_read_parameters" {
  name   = "${var.name}-TaskReadParameters"
  policy = data.aws_iam_policy_document.task_read_parameters.json
  role   = aws_iam_role.execution.id
}

resource "aws_ecs_task_definition" "task_definition" {
  family = "cloud_scanning"

  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"

  task_role_arn = aws_iam_role.task.arn

  execution_role_arn = aws_iam_role.execution.arn

  cpu    = "256"
  memory = "512"

  container_definitions = jsonencode([
    {
      environment      = local.task_env_vars
      name             = "CloudScanning"
      image            = var.image
      essential        = true
      secrets          = [
        {
          name      = "SECURE_URL"
          valueFrom = data.aws_ssm_parameter.endpoint.arn
        },
        {
          name      = "SECURE_API_TOKEN"
          valueFrom = data.aws_ssm_parameter.api_token.arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
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
  name        = var.name
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
  tags        = {
    "Name" : var.name
  }
}

data "aws_ecs_cluster" "ecs" {
  cluster_name = var.ecs_cluster
}

resource "aws_ecs_service" "service" {
  name            = var.name
  cluster         = data.aws_ecs_cluster.ecs.id
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = var.subnets
    security_groups = [aws_security_group.sg.id]
  }
  task_definition = aws_ecs_task_definition.task_definition.arn
}

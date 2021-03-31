locals {
  default_config = <<CONFIG
secureURL: "value overriden by SECURE_URL env var"
logLevel: "debug"
schedule: "24h"
benchmarkType: "aws"
outputDir: "/tmp/cloud-custodian"
policyFile: "/home/custodian/aws-benchmarks.yml"
CONFIG
  task_env_vars = concat([
    {
      name  = "VERIFY_SSL"
      value = tostring(var.verify_ssl)
    },
    ], flatten([for env_key, env_value in var.extra_env_vars : [{
      name  = env_key,
      value = env_value
    }]])
  )
  config_env_vars = [
    {
      name  = "BUCKET"
      value = var.config_bucket
    },
    {
      name  = "KEY"
      value = "cloud-bench.yaml"
    },
    {
      name  = "OUTPUT"
      value = "/etc/cloud-bench/cloud-bench.yaml"
    },
    {
      name  = "CONFIG"
      value = base64encode(local.default_config)
    }
  ]
}

data "aws_ssm_parameter" "endpoint" {
  name = var.ssm_endpoint
}

data "aws_ssm_parameter" "api_token" {
  name = var.ssm_token
}

data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "log" {
  name_prefix       = var.name
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

resource "aws_iam_role" "task" {
  assume_role_policy = data.aws_iam_policy_document.task_assume_role.json
  path               = "/"
}

data "aws_iam_policy_document" "iam_role_task_policy" {
  statement {
    effect = "Allow"
    actions = [ // TODO Do not add so much permissions
      "access-analyzer:List*",
      "acm:List*",
      "cloudtrail:DescribeTrails",
      "cloudtrail:Get*",
      "cloudwatch:Describe*",
      "cloudwatch:PutMetricData",
      "config:Describe*",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:Describe*",
      "elasticloadbalancing:DescribeLoadBalancers",
      "events:PutRule",
      "events:PutTargets",
      "iam:DeleteAccessKey",
      "iam:GenerateCredentialReport",
      "iam:Get*",
      "iam:List*",
      "iam:UpdateAccessKey",
      "lambda:AddPermission",
      "lambda:CreateAlias",
      "lambda:CreateEventSourceMapping",
      "lambda:CreateFunction",
      "lambda:DeleteAlias",
      "lambda:DeleteEventSourceMapping",
      "lambda:DeleteFunction",
      "lambda:DeleteFunctionConcurrency",
      "lambda:InvokeFunction",
      "lambda:PutFunctionConcurrency",
      "lambda:RemovePermission",
      "lambda:TagResource",
      "lambda:UntagResource",
      "lambda:UpdateAlias",
      "lambda:UpdateEventSourceMapping",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:Describe*",
      "kms:ListAliases",
      "kms:ListKeys",
      "kms:DescribeKey",
      "kms:GetKeyRotationStatus",
      "s3:Get*",
      "s3:List*",
      "s3:Put*",
      "sns:ListSubscriptionsByTopic",
      "tag:GetResources",
    ]
    // TODO Add the only resources needed for this policy to work with
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "task" {
  policy = data.aws_iam_policy_document.iam_role_task_policy.json
  role   = aws_iam_role.task.id
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

resource "aws_iam_role" "execution" {
  assume_role_policy = data.aws_iam_policy_document.execution_assume_role.json
  path               = "/"
}

data "aws_iam_policy_document" "execution" {
  statement {
    effect = "Allow"
    actions = [
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
  family = "cloud_bench"

  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"

  task_role_arn = aws_iam_role.task.arn

  execution_role_arn = aws_iam_role.execution.arn

  cpu    = "256"
  memory = "512"

  volume {
    name = "config"
  }

  container_definitions = jsonencode([
    {
      environment = local.config_env_vars
      name        = "Config"
      image       = var.config_image
      essential   = false
      mountPoints = [
        {
          sourceVolume  = "config"
          containerPath = "/etc/cloud-bench"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.log.id
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }
    },
    {
      name        = "CloudBench"
      environment = local.task_env_vars
      dependsOn = [
        {
          containerName = "Config"
          condition     = "SUCCESS"
        }
      ]
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
      image     = var.image
      essential = true
      portMappings = [{
        containerPort = 7000
      }]
      mountPoints = [
        {
          sourceVolume  = "config"
          containerPath = "/etc/cloud-bench"
        }
      ]
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
  name        = var.name
  description = "CloudConnector workload Security Group"
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
    "Name" : var.name
  }
}

data "aws_ecs_cluster" "ecs" {
  cluster_name = var.ecs_cluster
}

resource "aws_ecs_service" "service" {
  name          = var.name
  cluster       = data.aws_ecs_cluster.ecs.id
  desired_count = 1
  launch_type   = "FARGATE"
  network_configuration {
    subnets         = var.subnets
    security_groups = [aws_security_group.sg.id]
  }
  task_definition = aws_ecs_task_definition.task_definition.arn
}

data "aws_s3_bucket" "config" {
  bucket = var.config_bucket
}

resource "aws_s3_bucket_object" "config" {
  bucket  = data.aws_s3_bucket.config.id
  key     = "cloud-bench.yaml"
  content = var.config_content == null && var.config_source == null ? local.default_config : var.config_content
  source  = var.config_source
}

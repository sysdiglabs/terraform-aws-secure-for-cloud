locals {
  single_account              = length(var.accounts_and_regions) == 0
  accounts_and_regions_string = join(",", [for a in var.accounts_and_regions : "${a.account_id}:${a.region}"])
  account_role                = local.single_account ? "" : "${var.naming_prefix}-CloudBenchRole"
  default_config              = <<CONFIG
secureURL: "value overriden by SECURE_URL env var"
logLevel: "debug"
schedule: "24h"
benchmarkType: "aws"
outputDir: "/tmp/cloud-custodian"
policyFile: "/home/custodian/aws-benchmarks.yml"
accountsAndRegions: ${local.accounts_and_regions_string}
accountRole: ${local.account_role}
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
      value = var.s3_config_bucket
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
  name_prefix       = "${var.naming_prefix}-CloudBench"
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

data "aws_iam_policy_document" "config_bucket_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = ["arn:aws:s3:::${var.s3_config_bucket}"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["arn:aws:s3:::${var.s3_config_bucket}/*"]
  }
}

data "aws_iam_policy_document" "cloud_custodian_executor" {
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

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    resources = ["arn:aws:iam::*:role/${var.naming_prefix}-CloudBenchRole"]
  }
}

resource "aws_iam_role" "task" {
  name               = "${var.naming_prefix}-CloudBenchTaskRole"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role.json
  path               = "/"

  inline_policy {
    name   = "ConfigBucketAccess"
    policy = data.aws_iam_policy_document.config_bucket_access.json
  }

  dynamic "inline_policy" {
    for_each = local.single_account ? [1] : []
    content {
      name   = "CloudCustodianExecutor"
      policy = data.aws_iam_policy_document.cloud_custodian_executor.json
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
  name               = "${var.naming_prefix}-CloudBenchExecutionRole"
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
  family                   = "cloud_bench"
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.task.arn
  execution_role_arn       = aws_iam_role.execution.arn
  cpu                      = "256"
  memory                   = "512"

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
  name_prefix = "${var.naming_prefix}-CloudBench"

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
    "Name" : "${var.naming_prefix}-CloudBench"
  }
}

data "aws_ecs_cluster" "ecs" {
  cluster_name = var.ecs_cluster
}

resource "aws_ecs_service" "service" {
  name          = "${var.naming_prefix}-CloudBench"
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
  bucket = var.s3_config_bucket
}

resource "aws_s3_bucket_object" "config" {
  bucket  = data.aws_s3_bucket.config.id
  key     = "cloud-bench.yaml"
  content = var.config_content == null && var.config_source == null ? local.default_config : var.config_content
  source  = var.config_source
}

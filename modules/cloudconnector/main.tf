locals {
  single_account              = length(var.accounts_and_regions) == 0
  sqs_ingestor                = local.single_account ? "cloudtrail-sns-sqs" : "cloudtrail-sns-sqs-multiaccount"
  queue_url                   = local.single_account ? "https://sqs.${data.aws_region.current.name}.amazonaws.com/${data.aws_caller_identity.current.account_id}/${var.naming_prefix}-CloudConnector" : ""
  accounts_and_regions_string = join(",", [for a in var.accounts_and_regions : "${a.account_id}:${a.region}"])
  account_role                = local.single_account ? "" : "${var.naming_prefix}-CloudConnectorRole"
  queue_name                  = local.single_account ? "" : "${var.naming_prefix}-CloudConnector"
  default_config              = <<EOF
rules:
  - secure:
      url: ""
  - s3:
      bucket: ${var.s3_config_bucket}
      path: rules
ingestors:
  - ${local.sqs_ingestor}:
      interval: 25s
      queueURL: ${local.queue_url}
      accountsAndRegions: ${local.accounts_and_regions_string}
      accountRole: ${local.account_role}
      queueName: ${local.queue_name}
notifiers:
  - cloudwatch:
      logGroup: ${aws_cloudwatch_log_group.log.name}
      logStream: ${aws_cloudwatch_log_stream.stream.name}
  - securityhub:
      productArn: arn:aws:securityhub:${data.aws_region.current.name}::product/sysdig/sysdig-cloud-connector
  - secure:
      url: ""
EOF
  task_env_vars = concat([
    {
      name  = "VERIFY_SSL"
      value = tostring(var.verify_ssl)
    },
    {
      name  = "TELEMETRY_DEPLOYMENT_METHOD"
      value = "terraform"
    },
    {
      name  = "CONFIG_PATH"
      value = "s3://${var.s3_config_bucket}/cloud-connector.yaml"
    }
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

resource "aws_cloudwatch_log_group" "log" {
  name_prefix       = "${var.naming_prefix}-CloudConnector"
  retention_in_days = var.log_retention
}

resource "aws_cloudwatch_log_stream" "stream" {
  log_group_name = aws_cloudwatch_log_group.log.name
  name           = "alerts"
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

data "aws_iam_policy_document" "securityhub_publisher" {
  statement {
    effect = "Allow"
    actions = [
      "securityhub:GetFindings",
      "securityhub:BatchImportFindings",
    ]
    resources = ["*"]
  }
}


data "aws_iam_policy_document" "cloudwatch_publisher" {
  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
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

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    resources = ["arn:aws:iam::*:role/${var.naming_prefix}-CloudConnectorRole"]
  }
}

resource "aws_iam_role" "task" {
  name               = "${var.naming_prefix}-CloudConnectorTaskRole"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role.json
  path               = "/"

  inline_policy {
    name   = "ConfigBucketAccess"
    policy = data.aws_iam_policy_document.config_bucket_access.json
  }

  inline_policy {
    name   = "SecurityHubPublisher"
    policy = data.aws_iam_policy_document.securityhub_publisher.json
  }

  inline_policy {
    name   = "CloudWatchPublisher"
    policy = data.aws_iam_policy_document.cloudwatch_publisher.json
  }

  dynamic "inline_policy" {
    for_each = local.single_account ? [1] : []
    content {
      name   = "CloudTrailIngestor"
      policy = data.aws_iam_policy_document.cloudtrail_ingestor.json
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
  name               = "${var.naming_prefix}-CloudConnectorExecutionRole"
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
  family                   = "cloud_connector"
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
      name      = "CloudConnector"
      image     = var.image
      essential = true
      portMappings = [{
        containerPort = 5000
      }]
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
  name_prefix = "${var.naming_prefix}-CloudConnector"

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
    "Name" : "${var.naming_prefix}-CloudConnector"
  }
}

data "aws_ecs_cluster" "ecs" {
  cluster_name = var.ecs_cluster
}

resource "aws_ecs_service" "service" {
  name          = "${var.naming_prefix}-CloudConnector"
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
  key     = "cloud-connector.yaml"
  content = var.config_content == null && var.config_source == null ? local.default_config : var.config_content
  source  = var.config_source
}

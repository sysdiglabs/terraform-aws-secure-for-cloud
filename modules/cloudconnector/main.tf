locals {
  default_config = <<CONFIG
logging: info
rules:
  - secure:
      url: ""
  - s3:
      bucket: ${var.config_bucket}
      path: rules
ingestors:
  - cloudtrail-sns-sqs:
      queueURL: ${aws_sqs_queue.sqs.id}
      interval: 25s
notifiers:
  - cloudwatch:
      logGroup: ${aws_cloudwatch_log_group.log.name}
      logStream: ${aws_cloudwatch_log_stream.stream.name}
  - securityhub:
      productArn: arn:aws:securityhub:${data.aws_region.current.name}::product/sysdig/sysdig-cloud-connector
  - secure:
      url: ""
CONFIG
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
      name  = "FEAT_REGISTER_ACCOUNT_IN_SECURE"
      value = "true"
    },
    {
      name  = "CONFIG_PATH"
      value = "s3://${var.config_bucket}/cloud-connector.yaml"
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

resource "aws_sqs_queue" "sqs" {
}

data "aws_iam_policy_document" "sqs_queue" {
  statement {
    sid    = "Allow CloudTrail to send messages"
    effect = "Allow"
    principals {
      identifiers = ["sns.amazonaws.com"]
      type        = "Service"
    }
    actions = [
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
  count     = length(var.sns_topic_arns)
  endpoint  = aws_sqs_queue.sqs.arn
  protocol  = "sqs"
  topic_arn = var.sns_topic_arns[count.index]
}

resource "aws_cloudwatch_log_group" "log" {
  name_prefix       = var.name
  retention_in_days = var.log_retention
}

resource "aws_cloudwatch_log_stream" "stream" {
  name           = "alerts"
  log_group_name = aws_cloudwatch_log_group.log.name
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
      "s3:GetObject",
      "s3:ListBucket",
      "securityhub:GetFindings",
      "securityhub:BatchImportFindings",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
      "logs:PutLogEvents",
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
  family = "cloud_connector"

  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"

  task_role_arn = aws_iam_role.task.arn

  execution_role_arn = aws_iam_role.execution.arn

  cpu    = "256"
  memory = "512"

  container_definitions = jsonencode([
    {
      environment = local.task_env_vars
      name        = "CloudConnector"
      image       = var.image
      essential   = true
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
  key     = "cloud-connector.yaml"
  content = var.config_content == null && var.config_source == null ? local.default_config : var.config_content
  source  = var.config_source
}

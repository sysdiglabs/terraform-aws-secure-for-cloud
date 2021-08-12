data "aws_ecs_cluster" "ecs" {
  cluster_name = var.ecs_cluster
}

resource "aws_ecs_service" "service" {
  name          = var.name
  cluster       = data.aws_ecs_cluster.ecs.id
  desired_count = 1
  launch_type   = "FARGATE"

  network_configuration {
    subnets         = var.vpc_subnets
    security_groups = [aws_security_group.sg.id]
  }
  task_definition = aws_ecs_task_definition.task_definition.arn
  tags            = var.tags
}


resource "aws_ecs_task_definition" "task_definition" {
  family                   = "${var.name}-cloud_scanning"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.execution.arn # ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume
  task_role_arn            = aws_iam_role.task.arn      # ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS resource-group.
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      environment = local.task_env_vars
      name        = "CloudScanning"
      image       = var.image
      essential   = true
      secrets = [
        {
          name      = "SECURE_API_TOKEN"
          valueFrom = aws_ssm_parameter.secure_api_token.name
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
  tags = var.tags
}

locals {
  task_env_vars = concat([
    {
      name  = "VERIFY_SSL"
      value = tostring(local.verify_ssl)
    },
    {
      name  = "TELEMETRY_DEPLOYMENT_METHOD"
      value = "terraform"
    },
    {
      name  = "SECURE_URL"
      value = var.sysdig_secure_endpoint
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
      value = var.build_project_name
    },
    {
      name  = "SECURE_API_TOKEN_SECRET"
      value = aws_ssm_parameter.secure_api_token.name
    }
    ], flatten([for env_key, env_value in var.extra_env_vars : [{
      name  = env_key,
      value = env_value
    }]])
  )
}
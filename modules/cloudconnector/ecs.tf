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
  tags = var.cloudvision_product_tags
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = "cloud_connector"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.task.arn
  execution_role_arn       = aws_iam_role.execution.arn
  cpu                      = "256"
  memory                   = "512"

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
  tags = var.cloudvision_product_tags
}
resource "aws_appautoscaling_target" "ecs_target" {
  count = var.enable_autoscaling ? 1 : 0

  max_capacity       = var.max_replicas
  min_capacity       = var.min_replicas
  resource_id        = "service/${data.aws_ecs_cluster.this.cluster_name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_ram_policy" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "scale-cloud-connector-ram-usage"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 30
    metric_aggregation_type = "Average"

    # Scale down on Memory usage if it's below 40% usage
    step_adjustment {
      metric_interval_upper_bound = -10
      scaling_adjustment          = -1
    }

    # Do not scale if Memory usage is between 40% and 60% usage
    step_adjustment {
      metric_interval_lower_bound = -10
      metric_interval_upper_bound = 10
      scaling_adjustment          = 0
    }

    # Scale up on Memory usage if it's above 60% usage
    step_adjustment {
      metric_interval_lower_bound = 10
      scaling_adjustment          = 1
    }

  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_ram_usage" {
  count = var.enable_autoscaling ? 1 : 0

  alarm_name = "Step-Scaling-AlarmHigh-ECS:service/${data.aws_ecs_cluster.this.cluster_name}/${aws_ecs_service.service.name}"

  metric_name = "MemoryUtilization"
  namespace   = "AWS/EC2"
  statistic   = "Average"

  period             = "30"
  evaluation_periods = "2"
  threshold          = "50"

  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    Name        = data.aws_ecs_cluster.this.cluster_name,
    ServiceName = aws_ecs_service.service.name
  }

  alarm_actions = [aws_appautoscaling_policy.ecs_ram_policy[0].arn]

  alarm_description = "This metric monitors ECS Memory Utilization of Cloud Connector"
}

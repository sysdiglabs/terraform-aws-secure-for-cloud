resource "aws_appautoscaling_target" "ecs_target" {
  count = var.enable_autoscaling ? 1 : 0

  max_capacity       = var.autoscaling_config.max_replicas
  min_capacity       = var.autoscaling_config.min_replicas
  resource_id        = "service/${local.cluster_name}/${var.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}


# upscale memory > threshold
resource "aws_appautoscaling_policy" "ecs_memory_above" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "scale-cloud-connector-ram-above"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 30
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_above" {
  count = var.enable_autoscaling ? 1 : 0

  alarm_name        = "Step-Scaling-Alarm-Upscale-ECS:service/${local.cluster_name}/${aws_ecs_service.service.name}"
  alarm_description = "ECS cloud-connector service is above memory utilization threshold"

  metric_name = "MemoryUtilization"
  namespace   = "AWS/ECS"
  statistic   = "Average"

  period             = "60" # minimum 60 seconds
  evaluation_periods = "1"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = var.autoscaling_config.upscale_threshold
  alarm_actions       = [aws_appautoscaling_policy.ecs_memory_above[0].arn]

  dimensions = {
    ClusterName = local.cluster_name,
    ServiceName = aws_ecs_service.service.name
  }
}



# downscale memory > threshold
resource "aws_appautoscaling_policy" "ecs_memory_below" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "scale-cloud-connector-ram-below"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 30
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      metric_interval_lower_bound = -var.autoscaling_config.interval_change
      scaling_adjustment          = 0
    }

    step_adjustment {
      metric_interval_upper_bound = -var.autoscaling_config.interval_change
      scaling_adjustment          = -1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_below" {
  count = var.enable_autoscaling ? 1 : 0

  alarm_name        = "Step-Scaling-Alarm-Dowscale-ECS:service/${local.cluster_name}/${aws_ecs_service.service.name}"
  alarm_description = "ECS cloud-connector service is below memory utilization threshold"

  metric_name = "MemoryUtilization"
  namespace   = "AWS/ECS"
  statistic   = "Average"

  period             = "60" # minimum 60 seconds
  evaluation_periods = "1"

  threshold           = var.autoscaling_config.downscale_threshold
  comparison_operator = "LessThanThreshold"
  alarm_actions       = [aws_appautoscaling_policy.ecs_memory_below[0].arn]

  dimensions = {
    ClusterName = local.cluster_name,
    ServiceName = aws_ecs_service.service.name
  }
}

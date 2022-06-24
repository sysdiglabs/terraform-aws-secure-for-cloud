output "cloudtrail_sns_topic_arn" {
  value       = length(module.cloudtrail) > 0 ? module.cloudtrail[0].sns_topic_arn : var.cloudtrail_sns_arn
  description = "ARN of cloudtrail_sns topic"
}

output "cloudconnector_iam_role" {
  value = module.cloudconnector.ecs_task_role_arn
  description = "ARN of cloudconnector ecs_task role"
}
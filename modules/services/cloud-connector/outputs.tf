output "ecs_task_role_name" {
  value       = aws_iam_role.task.name
  description = "cloudconnect ecs task role name"
}

output "ecs_task_role_arn" {
  value       = aws_iam_role.task.arn
  description = "cloudconnect ecs task role arn"
}

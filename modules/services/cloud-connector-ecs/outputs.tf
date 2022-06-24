output "ecs_task_role_arn" {
    value = aws_iam_role.task.arn
    description = "ECS task role with permissions to CloudTrail s3 logs and SNS notifications through SQS."
}
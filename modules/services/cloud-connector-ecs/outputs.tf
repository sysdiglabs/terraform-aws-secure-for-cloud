output "ecs_task_role_arn" {
    value = var.is_organizational ? data.aws_iam_role.task_inherited[0].arn : aws_iam_role.task[0].arn
    description = "ECS task role with permissions to CloudTrail s3 logs and SNS notifications through SQS."
}
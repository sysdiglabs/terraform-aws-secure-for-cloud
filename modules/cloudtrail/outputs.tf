output "sns_topic_arn" {
  value       = local.deploy_cloudtrail ? aws_sns_topic.sns[0].arn : var.existing_cloudtrail_sns_topic
  description = "SNS Topic where CloudTrail events are published"
}

output "sqs_cloudconnector" {
  value       = aws_sqs_queue.sqs_cloudconnector.arn
  description = " SQS Queue for CloudConnector notifications"
}

output "sqs_cloudscanning" {
  value       = aws_sqs_queue.sqs_cloudscanning.arn
  description = "SQS Queue for CloudScanning notifications"
}

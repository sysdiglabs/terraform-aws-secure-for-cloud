output "sns_topic_arn" {
  value       = aws_sns_topic.cloudtrail.arn
  description = "ARN of Cloudtrail SNS topic"
}

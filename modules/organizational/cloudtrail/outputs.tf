output "sns_topic_arn" {
  value       = aws_sns_topic.cloudtrail.arn
  description = "ARN of the SNS topic"
}
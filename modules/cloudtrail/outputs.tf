output "topic_arn" {
  value       = aws_sns_topic.sns.arn
  description = "ARN of the SNS topic"
}
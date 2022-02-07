output "sns_topic_arn" {
  value       = aws_sns_topic.cloudtrail.arn
  description = "ARN of Cloudtrail SNS topic"
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.cloudtrail.arn
  description = "ARN of Cloudtrail SNS topic"
}

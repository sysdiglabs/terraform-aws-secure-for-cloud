output "sns_topic_arn" {
  value       = aws_sns_topic.cloudtrail.arn
  description = "Cloudtrail SNS topic ARN"
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.cloudtrail.arn
  description = "Cloudtrail S3 bucket ARN"
}

output "cloudvision_role_arn" {
  value       = aws_iam_role.cloudvision_role.arn
  description = "organizational cloudvision role arn"
}

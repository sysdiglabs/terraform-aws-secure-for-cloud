output "cloudtrail_subscribed_sqs_arn" {
  value       = module.cloudtrail_s3_sns_sqs.cloudtrail_sns_subscribed_sqs_arn
  description = "ARN of the SQS topic subscribed to the SNS of Cloudtrail-S3 bucket"
}

output "cloudtrail_s3_arn" {
  value       = data.aws_s3_bucket.cloudtrail_s3.arn
  description = "ARN of the SQS topic subscribed to the SNS of Cloudtrail-S3 bucket"
}

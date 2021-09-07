output "cloudtrail_sns_subscribed_sqs_url" {
  value       = aws_sqs_queue.this.url
  description = "URL of the cloudtrail-sns subscribed sqs"
}

output "cloudtrail_sns_subscribed_sqs_arn" {
  value       = aws_sqs_queue.this.arn
  description = "ARN of the cloudtrail-sns subscribed sqs"
}

output "sqs_url" {
  value       = aws_sqs_queue.sqs.url
  description = "Queue URL"
}

output "sfc_user_name" {
  value       = aws_iam_user.this.name
  description = "Name of the Secure for cloud Provisioned IAM user"
}

output "sfc_user_arn" {
  value       = aws_iam_user.this.arn
  description = "ARN of the Secure for cloud Provisioned IAM user"
}

output "sfc_user_access_key_id" {
  value       = aws_iam_access_key.this.id
  description = "Secure for cloud Provisioned user accessKey"
  sensitive   = true
}

output "sfc_user_secret_access_key" {
  value       = aws_iam_access_key.this.secret
  description = "Secure for cloud Provisioned user secretAccessKey"
  sensitive   = true
}

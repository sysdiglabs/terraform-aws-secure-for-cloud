output "s4c_user_access_key_id" {
  value       = aws_iam_access_key.this.id
  description = "Secure-for-cloud Provisioned user accessKey"
}


output "s4c_user_secret_access_key" {
  value       = aws_iam_access_key.this.secret
  description = "Secure-for-cloud Provisioned user secretAccessKey"
}

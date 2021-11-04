output "secure_api_token_secret_name" {
  value       = aws_ssm_parameter.secure_api_token.name
  description = "Name of Sysdig Secure API Token secret"
}

output "secure_api_token_secret_arn" {
  value       = aws_ssm_parameter.secure_api_token.arn
  description = "ARN of Sysdig Secure API Token secret"
}

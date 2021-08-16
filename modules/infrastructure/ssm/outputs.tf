output "secure_api_token_secret_name" {
  value       = aws_ssm_parameter.secure_api_token.name
  description = "Sysdig Secure API Token secret name"
}

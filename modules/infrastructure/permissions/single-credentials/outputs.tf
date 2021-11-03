output "sfc_user_name" {
  value       = module.credentials_general.sfc_user_name
  description = "Name of the Secure for cloud Provisioned IAM user"
}

output "sfc_user_access_key_id" {
  value       = module.credentials_general.sfc_user_access_key_id
  description = "Secure for cloud Provisioned user accessKey"
  sensitive   = true
}

output "sfc_user_secret_access_key" {
  value       = module.credentials_general.sfc_user_secret_access_key
  description = "Secure for cloud Provisioned user secretAccessKey"
  sensitive   = true
}

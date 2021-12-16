output "sysdig_secure_for_cloud_role_arn" {
  value       = aws_iam_role.secure_for_cloud_role.arn
  description = "organizational secure-for-cloud role arn"
}

output "sysdig_secure_for_cloud_role_name" {
  value       = aws_iam_role.secure_for_cloud_role.name
  description = "organizational secure-for-cloud role name"
}

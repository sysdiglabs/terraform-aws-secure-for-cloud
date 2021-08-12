output "cloudvision_role_arn" {
  value       = aws_iam_role.cloudvision_role.arn
  description = "organizational cloudvision role arn"
}

output "cloudvision_role_name" {
  value       = aws_iam_role.cloudvision_role.name
  description = "organizational cloudvision role name"
}

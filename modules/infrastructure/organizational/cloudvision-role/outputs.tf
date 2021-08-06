output "cloudvision_role_arn" {
  value       = length(aws_iam_role.cloudvision_role) > 0 ? aws_iam_role.cloudvision_role[0].arn : "n/a"
  description = "organizational cloudvision role arn"
}

output "project_arn" {
  description = "Code Build project arn"
  value       = aws_codebuild_project.build-project.arn
}

output "project_name" {
  description = "Code Build project name"
  value       = aws_codebuild_project.build-project.name
}
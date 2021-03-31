output "project_id" {
  value       = aws_codebuild_project.build_project.id
  description = "ID of the CodeBuild project"
}

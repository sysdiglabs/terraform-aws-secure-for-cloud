resource "aws_cloudwatch_log_group" "log" {
  name              = var.name
  retention_in_days = var.cloudwatch_log_retention
  tags              = var.tags
}

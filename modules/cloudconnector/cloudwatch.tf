resource "aws_cloudwatch_log_group" "log" {
  name_prefix       = var.name
  retention_in_days = var.log_retention
}

resource "aws_cloudwatch_log_stream" "stream" {
  name           = "alerts"
  log_group_name = aws_cloudwatch_log_group.log.name
}
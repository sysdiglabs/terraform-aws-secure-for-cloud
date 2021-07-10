resource "aws_cloudwatch_log_group" "log" {
  name_prefix       = var.name
  retention_in_days = var.cloudwatch_log_retention
  tags = var.cloudvision_product_tags
}

resource "aws_cloudwatch_log_stream" "stream" {
  name           = "alerts"
  log_group_name = aws_cloudwatch_log_group.log.name
}
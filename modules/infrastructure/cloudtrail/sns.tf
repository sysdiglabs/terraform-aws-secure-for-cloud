resource "aws_sns_topic" "cloudtrail" {
  name = var.name
  tags = var.tags
}

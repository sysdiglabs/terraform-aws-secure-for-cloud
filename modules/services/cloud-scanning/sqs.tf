module "cloud_scanning_sqs" {
  source        = "../../infrastructure/sqs-sns-subscription"
  name          = var.name
  sns_topic_arn = var.sns_topic_arn
  tags          = var.tags
}

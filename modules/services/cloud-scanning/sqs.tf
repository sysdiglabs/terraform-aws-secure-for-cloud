module "cloud_scanning_sqs" {
  source        = "../../../modules/infrastructure/cloudtrail-subscription-sqs"
  name          = var.name
  sns_topic_arn = var.sns_topic_arn
  tags          = var.tags
}

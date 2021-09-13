module "cloud_scanning_sqs" {
  source        = "../../../modules/infrastructure/cloudtrail-subscription-sqs"
  name          = "${var.name}-cloud_scanning"
  sns_topic_arn = var.sns_topic_arn
  tags          = var.tags
}

module "cloud_connector_sqs" {
  source        = "../../../modules/infrastructure/cloudtrail-subscription-sqs"
  name          = "${var.name}-cloud_connector"
  sns_topic_arn = var.sns_topic_arn
  tags          = var.tags
}

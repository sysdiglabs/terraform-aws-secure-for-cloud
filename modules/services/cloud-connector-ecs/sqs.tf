module "cloud_connector_sqs" {
  count  = var.cloudtrail_s3_sns_sqs_url == null ? 1 : 0
  source = "../../infrastructure/sqs-sns-subscription"

  name          = var.name
  cloudtrail_sns_arn = var.cloudtrail_sns_arn
  tags          = var.tags
}

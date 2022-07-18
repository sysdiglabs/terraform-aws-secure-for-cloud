locals {
  deploy_sqs = var.deploy_sqs && var.existing_cloudtrail_config.cloudtrail_s3_sns_sqs_url == null && var.guarduty_sqs_arn == null
}


module "cloud_connector_sqs" {
  count  = local.deploy_sqs ? 1 : 0
  source = "../../infrastructure/sqs-sns-subscription"

  name               = var.name
  cloudtrail_sns_arn = var.existing_cloudtrail_config.cloudtrail_sns_arn
  tags               = var.tags
}

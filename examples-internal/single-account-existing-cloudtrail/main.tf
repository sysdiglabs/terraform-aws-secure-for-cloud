provider "aws" {
  region = var.region
}

module "utils_cloudtrail" {
  source = "../../modules/infrastructure/cloudtrail"
  name   = "${var.name}-single-nocloudtrail"
}

module "cloudvision_aws_single_account" {
  source = "../../examples/single-account"
  name   = "${var.name}-single-nocloudtrail"

  sysdig_secure_api_token = var.sysdig_secure_api_token
  sysdig_secure_endpoint  = var.sysdig_secure_endpoint
  cloudtrail_sns_arn      = module.utils_cloudtrail.sns_topic_arn
}

locals {
  cloudtrail_deploy  = var.cloudtrail_sns_arn == "create"
  cloudtrail_sns_arn = local.cloudtrail_deploy ? module.cloudtrail[0].cloudtrail_sns_arn : var.cloudtrail_sns_arn
}

module "cloudtrail" {
  count                 = local.cloudtrail_deploy ? 1 : 0
  source                = "../../modules/infrastructure/cloudtrail"
  name                  = var.name
  is_organizational     = false
  is_multi_region_trail = var.cloudtrail_is_multi_region_trail
  cloudtrail_kms_enable = var.cloudtrail_kms_enable
  s3_bucket_expiration_days = var.cloudtrail_s3_bucket_expiration_days

  tags = var.tags
}

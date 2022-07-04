locals {
  cloudtrail_deploy  = var.cloudtrail_sns_arn == "create"
  cloudtrail_sns_arn = local.cloudtrail_deploy ? module.cloudtrail[0].sns_topic_arn : var.cloudtrail_sns_arn
  cloudtrail_s3_arn  = local.cloudtrail_deploy ? module.cloudtrail[0].s3_bucket_arn : var.cloudtrail_s3_arn
}


module "cloudtrail" {
  count  = local.cloudtrail_deploy ? 1 : 0
  source = "../../modules/infrastructure/cloudtrail"
  name   = var.name

  providers = {
    aws.member = aws.member
  }

  is_organizational = true
  organizational_config = {
    sysdig_secure_for_cloud_member_account_id = var.sysdig_secure_for_cloud_member_account_id
    organizational_role_per_account           = var.organizational_member_default_admin_role
  }
  is_multi_region_trail = var.cloudtrail_is_multi_region_trail
  cloudtrail_kms_enable = var.cloudtrail_kms_enable

  tags = var.tags
}

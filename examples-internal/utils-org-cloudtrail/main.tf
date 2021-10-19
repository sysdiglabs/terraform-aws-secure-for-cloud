provider "aws" {
  region = var.region
}

#-------------------------------------
# resources deployed always in management account
# with default provider
#-------------------------------------

module "resource_group" {
  source = "../../modules/infrastructure/resource-group"
  name   = var.name
  tags   = var.tags
}

module "cloudtrail" {
  source = "../../modules/infrastructure/cloudtrail"
  name   = var.name

  is_organizational = true
  organizational_config = {
    sysdig_secure_for_cloud_member_account_id = var.sysdig_secure_for_cloud_member_account_id
  }

  is_multi_region_trail = var.cloudtrail_is_multi_region_trail
  cloudtrail_kms_enable = var.cloudtrail_kms_enable

  tags = var.tags
}

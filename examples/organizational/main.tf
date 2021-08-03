provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

module "cloudvision" {
  source = "../../"

  sysdig_secure_endpoint  = var.sysdig_secure_endpoint
  sysdig_secure_api_token = var.sysdig_secure_api_token

  org_cloudvision_member_account_id = var.org_cloudvision_member_account_id
  org_cloudvision_account_region    = "eu-central-1"

  #  (optional) testing purpose; economization
  cloudtrail_org_is_multi_region_trail = false
  cloudtrail_org_kms_enable            = false
}

provider "aws" {
  profile = var.aws_connection_profile
  region  = var.org_master_account_region
}

module "cloudvision" {
  source = "../../"

  sysdig_secure_endpoint  = var.sysdig_secure_endpoint
  sysdig_secure_api_token = var.sysdig_secure_api_token

  org_cloudvision_account_id     = var.org_cloudvision_account_id
  org_cloudvision_account_region = "eu-central-1"

  // testing purpose; economization
  cloudtrail_org_is_multi_region_trail = false
  cloudtrail_org_kms_enable            = false
}

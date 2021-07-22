provider "aws" {
  profile = var.aws_connection_profile
  region  = var.region
}

module "cloudvision" {
  source = "../../"

  region                     = "eu-central-1"
  sysdig_secure_api_token    = var.sysdig_secure_api_token
  sysdig_secure_endpoint     = var.sysdig_secure_endpoint
  org_cloudvision_account_id = var.org_cloudvision_account_id

  // economization
  cloudtrail_org_is_multi_region_trail = false
  cloudtrail_org_s3_kms_enable         = false
}

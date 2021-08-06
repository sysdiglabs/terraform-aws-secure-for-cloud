provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

module "cloudvision" {
  source = "../../"

  name                    = var.name
  sysdig_secure_endpoint  = var.sysdig_secure_endpoint
  sysdig_secure_api_token = var.sysdig_secure_api_token

  cloudvision_organizational_setup = {
    is_organization_trail             = false
    org_cloudvision_account_region    = "eu-central-1"
    org_cloudvision_member_account_id = var.org_cloudvision_member_account_id
  }

  #  (optional) testing purpose; economization
  cloudtrail_org_is_multi_region_trail = false
  cloudtrail_org_kms_enable            = false
}

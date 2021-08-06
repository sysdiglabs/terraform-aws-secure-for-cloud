provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

module "cloudvision" {
  source = "../../"

  providers = {
    aws.cloudvision = aws
  }
  name                    = var.name
  sysdig_secure_endpoint  = var.sysdig_secure_endpoint
  sysdig_secure_api_token = var.sysdig_secure_api_token

  cloudvision_organizational_setup = {
    is_organizational                 = false
    org_cloudvision_member_account_id = null #FIXME add experimental optional vartype?
    cloudvision_role_arn              = null #FIXME add experimental optional vartype?
  }


  #  (optional) testing purpose; economization
  cloudtrail_org_is_multi_region_trail = false
  cloudtrail_org_kms_enable            = false
}

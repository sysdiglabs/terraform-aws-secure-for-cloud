provider "aws" {
  profile = var.terraform_connection_profile
  region  = var.region
}

module "cloudvision" {
  source = "../../"

  region                                               = "eu-central-1"
  sysdig_secure_api_token                              = var.sysdig_secure_api_token
  sysdig_secure_endpoint                               = var.sysdig_secure_endpoint
  aws_organization_cloudvision_account_id              = var.aws_organization_cloudvision_account_id
  aws_orgranization_cloudvision_account_creation_email = var.aws_orgranization_cloudvision_account_creation_email


  // economization
  cloudtrail_organizational_is_multi_region_trail = false
  cloudtrail_organizational_s3_kms_enable         = false
}

module "cloudvision" {
  source = "../../"

  region                          = "eu-central-1"
  sysdig_secure_api_token         = var.sysdig_secure_api_token
  sysdig_secure_endpoint          = var.sysdig_secure_endpoint
  aws_organization_sysdig_account = var.aws_organization_sysdig_account


  // economization
  cloudtrail_organizational_is_multi_region_trail = false
  cloudtrail_organizational_s3_kms_enable         = false
}

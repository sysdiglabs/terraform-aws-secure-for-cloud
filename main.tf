provider "aws" {
  alias   = "master"
  profile = var.terraform_connection_profile
  region  = var.region
}

#-------------------------------------
# cloudvision submodules
#-------------------------------------

module "cloudtrail_organizational" {
  source = "./modules/cloudtrail_organizational"
  providers = {
    aws = aws.master
  }

  cloudvision_account_id = (var.aws_organization_sysdig_account.create) ? aws_organizations_account.cloudvision[0].id : var.aws_organization_sysdig_account.param_use_account_id
  is_multi_region_trail  = var.cloudtrail_organizational_is_multi_region_trail
  s3_kms_enable          = var.cloudtrail_organizational_s3_kms_enable
  tags                   = var.tags
}


module "services" {
  source = "./modules/services"
  providers = {
    aws = aws.cloudvision
  }

  sysdig_secure_endpoint   = var.sysdig_secure_endpoint
  sysdig_secure_api_token  = var.sysdig_secure_api_token
  cloudtrail_sns_topic_arn = module.cloudtrail_organizational.sns_topic_arn
  services_assume_role_arn = aws_iam_role.cloudvision_role.arn
  tags                     = var.tags
}

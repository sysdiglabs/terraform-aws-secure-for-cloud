locals {
  cloudvision_account_id = var.org_cloudvision_account_creation_email != "" ? aws_organizations_account.cloudvision[0].id : var.org_cloudvision_account_id
}

provider "aws" {
  alias  = "cloudvision"
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::${local.cloudvision_account_id}:role/OrganizationAccountAccessRole"
  }
}

#-------------------------------------
# cloudvision submodules
#-------------------------------------

module "cloudtrail_organizational" {
  source = "./modules/cloudtrail_organizational"

  cloudvision_account_id = local.cloudvision_account_id
  is_multi_region_trail  = var.cloudtrail_org_is_multi_region_trail
  s3_kms_enable          = var.cloudtrail_org_s3_kms_enable
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

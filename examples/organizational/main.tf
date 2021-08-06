provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

provider "aws" {
  alias  = "member"
  region = "eu-central-1"
  assume_role {
    role_arn = "arn:aws:iam::${var.org_cloudvision_member_account_id}:role/OrganizationAccountAccessRole"
  }
}

module "cloudvision" {
  source = "../../"

  providers = {
    aws.cloudvision = aws.member
  }

  name                    = var.name
  sysdig_secure_endpoint  = var.sysdig_secure_endpoint
  sysdig_secure_api_token = var.sysdig_secure_api_token

  cloudvision_organizational_setup = {
    is_organizational                 = true
    org_cloudvision_member_account_id = var.org_cloudvision_member_account_id
  }

  #  (optional) testing purpose; economization
  cloudtrail_org_is_multi_region_trail = false
  cloudtrail_org_kms_enable            = false
}

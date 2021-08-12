provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "member"
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::${var.cloudvision_member_account_id}:role/OrganizationAccountAccessRole"
  }
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

<<<<<<< HEAD
  cloudvision_organizational_setup = {
    is_organizational                 = true
    connector_ecs_task_role_name      = var.connector_ecs_task_role_name
    org_cloudvision_role              = module.cloudvision_role.cloudvision_role_arn
    org_cloudvision_member_account_id = var.org_cloudvision_member_account_id
=======
  is_organizational = true
  organizational_config = {
    cloudvision_member_account_id = var.cloudvision_member_account_id
    connector_ecs_task_role_name  = var.connector_ecs_task_role_name
    cloudvision_role_arn          = module.cloudvision_role.cloudvision_role_arn
>>>>>>> master
  }

  #  (optional) testing purpose; economization
  cloudtrail_org_is_multi_region_trail = false
  cloudtrail_org_kms_enable            = false
}

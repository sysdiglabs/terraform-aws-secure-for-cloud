terraform {
  required_providers {
    aws = {
      version               = ">= 4.0.0"
      configuration_aliases = [aws.member]
    }
    sysdig = {
      source = "sysdiglabs/sysdig"
    }
  }
}

provider "sysdig" {
  sysdig_secure_api_token = var.sysdig_secure_api_token
  sysdig_secure_url       = var.sysdig_secure_url
}

provider "aws" {
  region = var.region
}


provider "aws" {
  alias  = "member"
  region = var.region
  assume_role {
    # 'OrganizationAccountAccessRole' is the default role created by AWS for management-account users to be able to admin member accounts.
    # <br/>https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_access.html
    role_arn = "arn:aws:iam::${var.sysdig_secure_for_cloud_member_account_id}:role/OrganizationAccountAccessRole"
  }
}

module "cloudvision_aws_organizational" {
  providers = {
    aws.member = aws.member
  }
  source = "../../../examples/organizational"
  name   = var.name

  sysdig_secure_for_cloud_member_account_id = var.sysdig_secure_for_cloud_member_account_id
  deploy_image_scanning_ecr                 = true
  deploy_image_scanning_ecs                 = true
  use_scanning_v2                           = false
}

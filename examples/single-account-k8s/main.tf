provider "aws" {
  region = var.region
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}


#-------------------------------------
# general resources
#-------------------------------------

module "resource_group" {
  source = "../../modules/infrastructure/resource-group"
  name   = var.name
  tags   = var.tags
}

module "ssm" {
  source                  = "../../modules/infrastructure/ssm"
  name                    = var.name
  sysdig_secure_api_token = var.sysdig_secure_api_token
}

module "cloudtrail" {
  source = "../../modules/infrastructure/cloudtrail"
  name   = var.name

  is_organizational     = false
  is_multi_region_trail = var.cloudtrail_is_multi_region_trail
  cloudtrail_kms_enable = var.cloudtrail_kms_enable

  tags = var.tags
}

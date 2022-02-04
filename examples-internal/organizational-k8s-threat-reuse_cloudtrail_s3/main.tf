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

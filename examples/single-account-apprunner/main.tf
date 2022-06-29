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
  sysdig_secure_api_token = data.sysdig_secure_connection.current.secure_api_token
  tags                    = var.tags
}


#-------------------------------------
# cloud-connector
#-------------------------------------
module "codebuild" {
  count = var.deploy_image_scanning_ecr || var.deploy_image_scanning_ecs ? 1 : 0

  source                       = "../../modules/infrastructure/codebuild"
  name                         = "${var.name}-codebuild"
  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name

  tags = var.tags
  # note. this is required to avoid race conditions
  depends_on = [module.ssm]
}

module "cloud_connector" {
  source = "../../modules/services/cloud-connector-apprunner"
  name   = "${var.name}-cloudconnector"

  sysdig_secure_api_token      = data.sysdig_secure_connection.current.secure_api_token
  sysdig_secure_url            = data.sysdig_secure_connection.current.secure_url
  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name
  secure_api_token_secret_arn  = module.ssm.secure_api_token_secret_arn

  build_project_arn  = length(module.codebuild) == 1 ? module.codebuild[0].project_arn : "na"
  build_project_name = length(module.codebuild) == 1 ? module.codebuild[0].project_name : "na"

  cloudconnector_ecr_image_uri = var.cloudconnector_ecr_image_uri
  deploy_image_scanning_ecr    = var.deploy_image_scanning_ecr
  deploy_image_scanning_ecs    = var.deploy_image_scanning_ecs

  cloudtrail_sns_arn = local.cloudtrail_sns_arn
  tags               = var.tags
}

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
  name = "${var.name}-cloudconnector"

  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name

  cloudconnector_config_path = var.cloudconnector_config_path
  cloudconnector_ecr_image_uri = var.cloudconnector_ecr_image_uri

  # why is needed
  sysdig_secure_api_token = data.sysdig_secure_connection.current.secure_api_token

  sns_topic_arn = local.cloudtrail_sns_arn
}
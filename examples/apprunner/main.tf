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


module "cloud_connector_sqs" {
  source        = "../../modules/infrastructure/sqs-sns-subscription"
  name          = "${var.name}-cloud_connector"
  sns_topic_arn = local.cloudtrail_sns_arn
  tags          = var.tags
}

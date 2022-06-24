locals {
  deploy_image_scanning = var.deploy_image_scanning_ecr || var.deploy_image_scanning_ecs
  deploy_scanning_infra = local.deploy_image_scanning && !var.use_standalone_scanner
}
#-------------------------------------
# general resources
#-------------------------------------
module "resource_group" {
  source = "../../modules/infrastructure/resource-group"

  name = var.name
  tags = var.tags
}

module "ssm" {
  source                  = "../../modules/infrastructure/ssm"
  name                    = var.name
  sysdig_secure_api_token = data.sysdig_secure_connection.current.secure_api_token
  tags                    = var.tags
}


#
# scanning
#

module "codebuild" {
  count = local.deploy_scanning_infra ? 1 : 0

  source                       = "../../modules/infrastructure/codebuild"
  name                         = "${var.name}-codebuild"
  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name

  tags = var.tags
  # note. this is required to avoid racing conditions
  depends_on = [module.ssm]
}


#
# threat-detection
#

module "cloud_connector" {
  source = "../../modules/services/cloud-connector-ecs"
  name   = "${var.name}-cloudconnector"

  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name

  deploy_image_scanning_ecr = var.deploy_image_scanning_ecr
  deploy_image_scanning_ecs = var.deploy_image_scanning_ecs
  use_standalone_scanner    = var.use_standalone_scanner

  is_organizational = false

  build_project_arn  = length(module.codebuild) == 1 ? module.codebuild[0].project_arn : "na"
  build_project_name = length(module.codebuild) == 1 ? module.codebuild[0].project_name : "na"

  sns_topic_arn = local.cloudtrail_sns_arn

  ecs_cluster_name            = local.ecs_cluster_name
  ecs_vpc_id                  = local.ecs_vpc_id
  ecs_vpc_subnets_private_ids = local.ecs_vpc_subnets_private_ids
  ecs_task_cpu                = var.ecs_task_cpu
  ecs_task_memory             = var.ecs_task_memory

  tags       = var.tags
  depends_on = [local.cloudtrail_sns_arn, module.ssm]
}

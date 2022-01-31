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


#-------------------------------------
# cloud-connector
#-------------------------------------
module "codebuild" {
  source                       = "../../modules/infrastructure/codebuild"
  name                         = "${var.name}-codebuild"
  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name

  tags = var.tags
  # note. this is required to avoid race conditions
  depends_on = [module.ssm]
}

module "cloud_connector" {
  source = "../../modules/services/cloud-connector"
  name   = "${var.name}-cloudconnector"

  sysdig_secure_endpoint       = var.sysdig_secure_endpoint
  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name
  is_organizational            = false

  build_project_arn  = module.codebuild.project_arn
  build_project_name = module.codebuild.project_name

  sns_topic_arn = local.cloudtrail_sns_arn

  ecs_cluster_id     = var.ecs_cluster_id
  ecs_vpc_id         = var.ecs_vpc_id
  ecs_vpc_region_azs = var.ecs_vpc_region_azs
  ecs_sg_id          = var.ecs_sg_id

  tags       = var.tags
  depends_on = [local.cloudtrail_sns_arn, module.ssm]

}

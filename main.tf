module "cloudtrail" {
  source                        = "./modules/cloudtrail"
  existing_cloudtrail_sns_topic = var.existing_cloudtrail_sns_topic
  naming_prefix                 = var.name
}

module "cloudvision_components" {
  source                               = "./modules/cloudvision-mainaccount"
  cloudconnector_deploy                = var.cloudconnector_deploy
  ecr_image_scanning_deploy            = var.ecr_image_scanning_deploy
  ecs_image_scanning_deploy            = var.ecs_image_scanning_deploy
  cloudbench_deploy                    = var.cloudbench_deploy
  existing_ecs_cluster                 = var.existing_ecs_cluster
  existing_ecs_cluster_vpc             = var.existing_ecs_cluster_vpc
  existing_ecs_cluster_private_subnets = var.existing_ecs_cluster_private_subnets
  sysdig_secure_api_token              = var.sysdig_secure_api_token
  sysdig_secure_endpoint               = var.sysdig_secure_endpoint
  naming_prefix                        = var.name
}

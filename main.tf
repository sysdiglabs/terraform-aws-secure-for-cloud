
#-------------------------------------
# master account
# with default provider
#-------------------------------------

module "resource_group_master" {
  source = "./modules/infrastructure/resource-group"
  name   = var.name
  tags   = var.tags
}

module "ssm" {
  source                  = "./modules/infrastructure/ssm"
  name                    = var.name
  sysdig_secure_api_token = var.sysdig_secure_api_token
}

module "codebuild" {
  source = "./modules/infrastructure/codebuild"
  name   = var.name

  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name

  depends_on = [module.ssm]
}


module "cloudtrail" {
  source = "./modules/infrastructure/cloudtrail"
  name   = var.name

  is_organizational = var.is_organizational
  organizational_config = {
    cloudvision_member_account_id = var.organizational_config.cloudvision_member_account_id
  }

  is_multi_region_trail = var.cloudtrail_is_multi_region_trail
  cloudtrail_kms_enable = var.cloudtrail_kms_enable

  tags = var.tags
}


module "ecs_fargate_cluster" {
  providers = {
    aws = aws.cloudvision
  }
  source = "./modules/infrastructure/ecs-fargate-cluster"
  name   = var.name
  tags   = var.tags
}



module "cloud_connector" {
  providers = {
    aws = aws.cloudvision
  }
  source = "./modules/services/cloud-connector"
  name   = "${var.name}-cloudconnector"

  sysdig_secure_endpoint = var.sysdig_secure_endpoint

  is_organizational = var.is_organizational
  oragnizational_config = {
    cloudvision_role_arn         = var.organizational_config.cloudvision_role_arn
    connector_ecs_task_role_name = var.organizational_config.connector_ecs_task_role_name
  }

  sns_topic_arn = module.cloudtrail.sns_topic_arn

  ecs_cluster = module.ecs_fargate_cluster.id
  vpc_id      = module.ecs_fargate_cluster.vpc_id
  vpc_subnets = module.ecs_fargate_cluster.vpc_subnets

  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name

  tags       = var.tags
  depends_on = [module.cloudtrail, module.ecs_fargate_cluster, module.ssm]
}



module "cloud_scanning" {
  providers = {
    aws = aws.cloudvision
  }

  source = "./modules/services/cloud-scanning"
  name   = "${var.name}-cloudscanning"

  sysdig_secure_endpoint = var.sysdig_secure_endpoint

  sns_topic_arn = module.cloudtrail.sns_topic_arn

  ecs_cluster = module.ecs_fargate_cluster.id
  vpc_id      = module.ecs_fargate_cluster.vpc_id
  vpc_subnets = module.ecs_fargate_cluster.vpc_subnets

  build_project_arn  = module.codebuild.project_arn
  build_project_name = module.codebuild.project_name

  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name


  tags       = var.tags
  depends_on = [module.cloudtrail, module.ecs_fargate_cluster, module.codebuild, module.ssm]

}

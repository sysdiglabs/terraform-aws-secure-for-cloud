#-------------------------------------
# master account
# with default provider
#-------------------------------------

module "resource_group_master" {
  source = "./modules/infrastructure/resource-group"
  name   = var.name
  tags   = var.tags
}



module "cloudtrail" {
  source = "./modules/infrastructure/cloudtrail"

  name = var.name

  is_organizational = var.is_organizational
  organizational_config = {
    cloudvision_member_account_id = var.organizational_config.cloudvision_member_account_id
  }
  is_multi_region_trail = var.cloudtrail_org_is_multi_region_trail
  cloudtrail_kms_enable = var.cloudtrail_org_kms_enable

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

  sysdig_secure_endpoint  = var.sysdig_secure_endpoint
  sysdig_secure_api_token = var.sysdig_secure_api_token

  is_organizational = var.is_organizational
  oragnizational_config = {
    cloudvision_role_arn         = var.organizational_config.cloudvision_role_arn
    connector_ecs_task_role_name = var.organizational_config.connector_ecs_task_role_name
  }

  sns_topic_arn = module.cloudtrail.sns_topic_arn

  ecs_cluster = module.ecs_fargate_cluster.id
  vpc_id      = module.ecs_fargate_cluster.vpc_id
  vpc_subnets = module.ecs_fargate_cluster.vpc_subnets

  tags       = var.tags
  depends_on = [module.cloudtrail, module.ecs_fargate_cluster]
}

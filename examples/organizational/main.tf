#-------------------------------------
# resources deployed always in management account
# with default provider
#-------------------------------------

module "resource_group" {
  source = "../../modules/infrastructure/resource-group"
  name   = var.name
  tags   = var.tags
}


#-------------------------------------
# secure-for-cloud member account workload
#-------------------------------------
module "ssm" {
  providers = {
    aws = aws.member
  }
  source                  = "../../modules/infrastructure/ssm"
  name                    = var.name
  sysdig_secure_api_token = data.sysdig_secure_connection.current.secure_api_token
}


#-------------------------------------
# cloud-connector
#-------------------------------------
module "codebuild" {
  count = var.deploy_image_scanning_ecr || var.deploy_image_scanning_ecs ? 1 : 0

  providers = {
    aws = aws.member
  }
  source                       = "../../modules/infrastructure/codebuild"
  name                         = var.name
  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name
  depends_on                   = [module.ssm]
}

module "cloud_connector" {
  providers = {
    aws = aws.member
  }
  source = "../../modules/services/cloud-connector"
  name   = "${var.name}-cloudconnector"

  sysdig_secure_endpoint       = data.sysdig_secure_connection.current.secure_url
  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name

  deploy_image_scanning_ecr = var.deploy_image_scanning_ecr
  deploy_image_scanning_ecs = var.deploy_image_scanning_ecs

  is_organizational = true
  organizational_config = {
    sysdig_secure_for_cloud_role_arn = module.secure_for_cloud_role.sysdig_secure_for_cloud_role_arn
    organizational_role_per_account  = var.organizational_member_default_admin_role
    connector_ecs_task_role_name     = aws_iam_role.connector_ecs_task.name
  }

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

#-------------------------------------
# cloud-bench
#-------------------------------------

module "cloud_bench" {
  source = "../../modules/services/cloud-bench"
  count  = var.deploy_benchmark ? 1 : 0

  name              = "${var.name}-cloudbench"
  is_organizational = true
  region            = data.aws_region.current.name
  benchmark_regions = var.benchmark_regions

  tags = var.tags
}

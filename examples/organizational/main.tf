#-------------------------------------
# resources deployed always in management account
# with default provider
#-------------------------------------
locals {
  deploy_same_account                      = data.aws_caller_identity.me.account_id == var.sysdig_secure_for_cloud_member_account_id
  deploy_old_image_scanning_with_codebuild = (var.deploy_image_scanning_ecr && !var.deploy_beta_image_scanning_ecr) || var.deploy_image_scanning_ecs
}

module "resource_group" {
  source = "../../modules/infrastructure/resource-group"
  name   = var.name
  tags   = var.tags
}

module "resource_group_secure_for_cloud_member" {
  count = local.deploy_same_account ? 0 : 1
  providers = {
    aws = aws.member
  }
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
  tags                    = var.tags
}


#-------------------------------------
# cloud-connector
#-------------------------------------
module "codebuild" {
  count = local.deploy_old_image_scanning_with_codebuild ? 1 : 0

  providers = {
    aws = aws.member
  }
  source                       = "../../modules/infrastructure/codebuild"
  name                         = var.name
  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name

  tags = var.tags
  # note. this is required to avoid race conditions
  depends_on = [module.ssm]
}

module "cloud_connector" {
  providers = {
    aws = aws.member
  }

  source = "../../modules/services/cloud-connector-ecs"
  name   = "${var.name}-cloudconnector"

  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name

  deploy_beta_image_scanning_ecr = var.deploy_beta_image_scanning_ecr
  deploy_image_scanning_ecr      = var.deploy_image_scanning_ecr
  deploy_image_scanning_ecs      = var.deploy_image_scanning_ecs

  #
  # note;
  # these two variables `is_organizational` and `organizational_config` is for image-scanning requirements (double inception)
  # this must still be true to be able to handle future image-scanning
  # is_organizational means that it will attempt an assumeRole on management account, as cloud_connector is deployed on `aws.member` alias
  #
  # TODO
  # - avoid all these parameters if `deploy_image_scanning_ecr` and `deploy_image_scanning_ecs` == false
  # - is_organizational to be renamed to enable_management_account_assume_role?
  # - we could check whether aws.member = aws (management account) infer the value of the variable
  #
  is_organizational = true
  organizational_config = {
    # see local.deploy_org_management_sysdig_role notes
    sysdig_secure_for_cloud_role_arn = local.deploy_org_management_sysdig_role ? module.secure_for_cloud_role[0].sysdig_secure_for_cloud_role_arn : var.existing_cloudtrail_config.cloudtrail_s3_role_arn
    organizational_role_per_account  = var.organizational_member_default_admin_role
    connector_ecs_task_role_name     = aws_iam_role.connector_ecs_task.name
  }

  build_project_arn  = length(module.codebuild) == 1 ? module.codebuild[0].project_arn : "na"
  build_project_name = length(module.codebuild) == 1 ? module.codebuild[0].project_name : "na"

  existing_cloudtrail_config = {
    cloudtrail_sns_arn        = local.cloudtrail_sns_arn
    cloudtrail_s3_sns_sqs_url = var.existing_cloudtrail_config.cloudtrail_s3_sns_sqs_url
    cloudtrail_s3_sns_sqs_arn = var.existing_cloudtrail_config.cloudtrail_s3_sns_sqs_arn
  }

  ecs_cluster_name            = local.ecs_cluster_name
  ecs_vpc_id                  = local.ecs_vpc_id
  ecs_vpc_subnets_private_ids = local.ecs_vpc_subnets_private_ids
  ecs_task_cpu                = var.ecs_task_cpu
  ecs_task_memory             = var.ecs_task_memory

  enable_autoscaling = var.enable_autoscaling
  autoscaling_config = {
    min_replicas        = var.autoscaling_config.min_replicas
    max_replicas        = var.autoscaling_config.max_replicas
    upscale_threshold   = var.autoscaling_config.upscale_threshold
    downscale_threshold = var.autoscaling_config.downscale_threshold
    interval_change     = var.autoscaling_config.interval_change
  }

  tags       = var.tags
  depends_on = [local.cloudtrail_sns_arn, module.ssm]
}

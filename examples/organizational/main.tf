provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "member"
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::${var.cloudvision_member_account_id}:role/OrganizationAccountAccessRole"
  }
}

# FIXME. refact verify_ssl so its handled in upper layers and passed downwards
locals {
  verify_ssl = length(regexall("https://.*?\\.sysdig(cloud)?.com/?", var.sysdig_secure_endpoint)) == 1 ? false : true
}

provider "sysdig" {
  sysdig_secure_url          = var.sysdig_secure_endpoint
  sysdig_secure_api_token    = var.sysdig_secure_api_token
  sysdig_secure_insecure_tls = local.verify_ssl
}

#-------------------------------------
# resources deployed always in master account
# with default provider
#-------------------------------------

module "resource_group_master" {
  source = "../../modules/infrastructure/resource-group"
  name   = var.name
  tags   = var.tags
}

module "cloudtrail" {
  source = "../../modules/infrastructure/cloudtrail"
  name   = var.name

  is_organizational = true
  organizational_config = {
    cloudvision_member_account_id = var.cloudvision_member_account_id
  }

  is_multi_region_trail = var.cloudtrail_is_multi_region_trail
  cloudtrail_kms_enable = var.cloudtrail_kms_enable

  tags = var.tags
}


#-------------------------------------
# resources deployed in master OR member account
# with cloudvision provider, which can be master or member config
#-------------------------------------

module "ecs_fargate_cluster" {
  providers = {
    aws = aws.member
  }
  source = "../../modules/infrastructure/ecs-fargate-cluster"
  name   = var.name
  tags   = var.tags
}


module "ssm" {
  providers = {
    aws = aws.member
  }
  source                  = "../../modules/infrastructure/ssm"
  name                    = var.name
  sysdig_secure_api_token = var.sysdig_secure_api_token
}



module "cloud_connector" {
  providers = {
    aws = aws.member
  }
  source = "../../modules/services/cloud-connector"
  name   = "${var.name}-cloudconnector"

  sysdig_secure_endpoint       = var.sysdig_secure_endpoint
  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name

  is_organizational = true
  organizational_config = {
    cloudvision_role_arn         = module.cloudvision_role.cloudvision_role_arn
    connector_ecs_task_role_name = aws_iam_role.connector_ecs_task.name
  }

  sns_topic_arn = module.cloudtrail.sns_topic_arn

  ecs_cluster = module.ecs_fargate_cluster.id
  vpc_id      = module.ecs_fargate_cluster.vpc_id
  vpc_subnets = module.ecs_fargate_cluster.vpc_subnets

  tags       = var.tags
  depends_on = [module.cloudtrail, module.ecs_fargate_cluster, module.ssm]
}





#data "aws_caller_identity" "me" {}
#module "cloud_bench" {
#  providers = {
#    aws = aws.member
#  }
#  source = "../../modules/services/cloud-bench"
#
#  account_id = var.organizational_config.cloudvision_member_account_id
#  tags       = var.tags
#}




## FIXME? if this is a non-shared resource, move its usage to scanning service?
#module "codebuild" {
#  source                       = "../../modules/infrastructure/codebuild"
#  name                         = var.name
#  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name
#  depends_on                   = [module.ssm]
#}
#


#module "cloud_scanning" {
#  providers = {
#    aws = aws.member
#  }
#
#  source = "../../modules/services/cloud-scanning"
#  name   = "${var.name}-cloudscanning"
#
#  sysdig_secure_endpoint       = var.sysdig_secure_endpoint
#  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name
#
#  build_project_arn  = module.codebuild.project_arn
#  build_project_name = module.codebuild.project_name
#
#  sns_topic_arn = module.cloudtrail.sns_topic_arn
#
#  ecs_cluster = module.ecs_fargate_cluster.id
#  vpc_id      = module.ecs_fargate_cluster.vpc_id
#  vpc_subnets = module.ecs_fargate_cluster.vpc_subnets
#
#  tags       = var.tags
#  depends_on = [module.cloudtrail, module.ecs_fargate_cluster, module.codebuild, module.ssm]
#}

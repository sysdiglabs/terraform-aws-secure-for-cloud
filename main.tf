#
# empty provider to pass `terraform validate`
# will be overrided by parent in real execution
# https://github.com/hashicorp/terraform/issues/21416
#
provider "aws" {
  alias = "cloudvision"
}




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

  organizational_setup  = var.cloudvision_organizational_setup
  is_multi_region_trail = var.cloudtrail_org_is_multi_region_trail
  cloudtrail_kms_enable = var.cloudtrail_org_kms_enable

  tags = var.tags
}


#-------------------------------------
# master/member account - only organizational use-case
#-------------------------------------
module "cloudvision_role" {
  # FIXME. count workaround for providers conflict within module
  create = var.cloudvision_organizational_setup.is_organizational

  source = "./modules/infrastructure/organizational/cloudvision-role"
  providers = {
    aws.member = aws.cloudvision
  }

  name = var.name

  cloudtrail_s3_arn               = module.cloudtrail.s3_bucket_arn
  cloudconnect_ecs_task_role_arn  = module.cloud_connector.ecs_task_role_arn
  cloudconnect_ecs_task_role_name = module.cloud_connector.ecs_task_role_name

  tags = var.tags
}


module "resource_group_cloudvision_member" {
  # FIXME. count workaround for providers conflict within module
  create = var.cloudvision_organizational_setup.is_organizational

  providers = {
    aws = aws.cloudvision
  }
  source = "./modules/infrastructure/resource-group"
  name   = var.name
  tags   = var.tags
}

#-------------------------------------
# member account - cloudvision services
# with 'organizational' aws provider alias
#-------------------------------------
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

  organizational_setup = {
    is_organizational        = var.cloudvision_organizational_setup.is_organizational
    services_assume_role_arn = module.cloudvision_role.cloudvision_role_arn #note. if non-organizational won't be used
  }
  sns_topic_arn = module.cloudtrail.sns_topic_arn

  ecs_cluster = module.ecs_fargate_cluster.id
  vpc_id      = module.ecs_fargate_cluster.vpc_id
  vpc_subnets = module.ecs_fargate_cluster.vpc_subnets

  tags       = var.tags
  depends_on = [module.cloudtrail, module.ecs_fargate_cluster]
}

#-------------------------------------
# master account
# with default provider
#-------------------------------------

module "resource_group_master" {
  source = "./modules/infrastructure/resource-group"
  name   = var.name
  tags   = var.tags
}



module "org_cloudtrail" {
  source = "./modules/infrastructure/cloudtrail"

  org_cloudvision_member_account_id = var.org_cloudvision_member_account_id
  is_multi_region_trail             = var.cloudtrail_org_is_multi_region_trail
  cloudtrail_kms_enable             = var.cloudtrail_org_kms_enable
  tags                              = var.tags
}

module "cloudvision_role" {
  source = "./modules/infrastructure/organizational/cloudvision-role"
  providers = {
    aws.member = aws.member
  }

  name = var.name

  cloudtrail_s3_arn               = module.org_cloudtrail.s3_bucket_arn
  cloudconnect_ecs_task_role_arn  = module.cloud_connector.ecs_task_role_arn
  cloudconnect_ecs_task_role_name = module.cloud_connector.ecs_task_role_name

  tags = var.tags
}

#-------------------------------------
# member account - cloudvision services
# with 'organizational' aws provider alias
#-------------------------------------
provider "aws" {
  alias  = "member"
  region = var.org_cloudvision_account_region
  assume_role {
    role_arn = "arn:aws:iam::${var.org_cloudvision_member_account_id}:role/OrganizationAccountAccessRole"
  }
}



module "resource_group_cloudvision_member" {
  providers = {
    aws = aws.member
  }
  source = "./modules/infrastructure/resource-group"
  name   = var.name
  tags   = var.tags
}


module "ecs_fargate_cluster" {
  providers = {
    aws = aws.member
  }
  source = "./modules/infrastructure/ecs-fargate-cluster"
  name   = var.name
  tags   = var.tags
}


module "cloud_connector" {
  providers = {
    aws = aws.member
  }
  source = "./modules/services/cloud-connector"
  name   = "${var.name}-cloudconnector"

  sysdig_secure_endpoint  = var.sysdig_secure_endpoint
  sysdig_secure_api_token = var.sysdig_secure_api_token

  services_assume_role_arn = module.cloudvision_role.cloudvision_role_arn
  sns_topic_arn            = module.org_cloudtrail.sns_topic_arn

  ecs_cluster = module.ecs_fargate_cluster.id
  vpc_id      = module.ecs_fargate_cluster.vpc_id
  vpc_subnets = module.ecs_fargate_cluster.vpc_subnets

  tags       = var.tags
  depends_on = [module.org_cloudtrail, module.ecs_fargate_cluster]
}

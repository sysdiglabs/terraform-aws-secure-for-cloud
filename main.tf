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
  source = "./modules/infrastructure/organizational/cloudtrail"

  org_cloudvision_account_id = var.org_cloudvision_account_id
  is_multi_region_trail      = var.cloudtrail_org_is_multi_region_trail
  cloudtrail_kms_enable      = var.cloudtrail_org_kms_enable
  tags                       = var.tags
}


#-------------------------------------
# member account - cloudvision services
# with 'organizational' aws provider alias
#-------------------------------------
provider "aws" {
  alias  = "cloudvision_org_member"
  region = var.org_cloudvision_account_region
  assume_role {
    role_arn = "arn:aws:iam::${var.org_cloudvision_account_id}:role/OrganizationAccountAccessRole"
  }
}

module "resource_group_cloudvision_member" {
  providers = {
    aws = aws.cloudvision_org_member
  }
  source = "./modules/infrastructure/resource-group"
  name   = var.name
  tags   = var.tags
}


module "ecs_fargate_cluster" {
  providers = {
    aws = aws.cloudvision_org_member
  }
  source = "./modules/infrastructure/ecscluster"
  name   = var.name
  tags   = var.tags
}


module "cloud_connector" {
  providers = {
    aws = aws.cloudvision_org_member
  }
  source = "./modules/services/cloud-connector"
  name   = "${var.name}-cloudconnector"

  sysdig_secure_endpoint  = var.sysdig_secure_endpoint
  sysdig_secure_api_token = var.sysdig_secure_api_token

  services_assume_role_arn = module.org_cloudtrail.cloudvision_role_arn
  sns_topic_arn            = module.org_cloudtrail.sns_topic_arn

  ecs_cluster = module.ecs_fargate_cluster.id
  vpc_id      = module.ecs_fargate_cluster.vpc_id
  vpc_subnets = module.ecs_fargate_cluster.vpc_subnets

  tags       = var.tags
  depends_on = [module.org_cloudtrail, module.ecs_fargate_cluster]
}

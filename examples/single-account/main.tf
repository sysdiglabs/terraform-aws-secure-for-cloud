provider "aws" {
  region = var.region
}


#-------------------------------------
# general resources
#-------------------------------------

module "resource_group" {
  source = "../../modules/infrastructure/resource-group"
  name   = var.name
  tags   = var.tags
}

module "cloudtrail" {
  source                = "../../modules/infrastructure/cloudtrail"
  name                  = var.name
  is_organizational     = false
  is_multi_region_trail = var.cloudtrail_is_multi_region_trail
  cloudtrail_kms_enable = var.cloudtrail_kms_enable

  tags = var.tags
}

module "ecs_fargate_cluster" {
  source = "../../modules/infrastructure/ecs-fargate-cluster"
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

module "cloud_connector" {
  source = "../../modules/services/cloud-connector"
  name   = "${var.name}-cloudconnector"

  sysdig_secure_endpoint       = var.sysdig_secure_endpoint
  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name
  is_organizational            = false

  sns_topic_arn = module.cloudtrail.sns_topic_arn

  ecs_cluster = module.ecs_fargate_cluster.id
  vpc_id      = module.ecs_fargate_cluster.vpc_id
  vpc_subnets = module.ecs_fargate_cluster.vpc_subnets

  tags       = var.tags
  depends_on = [module.cloudtrail, module.ecs_fargate_cluster, module.ssm]
}



#-------------------------------------
# cloud-scanning
#-------------------------------------

module "codebuild" {
  source                       = "../../modules/infrastructure/codebuild"
  name                         = "${var.name}-codebuild"
  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name

  tags = var.tags
  # note. this is required to avoid race conditions
  depends_on = [module.ssm]
}


module "cloud_scanning" {
  source = "../../modules/services/cloud-scanning"
  name   = "${var.name}-cloudscanning"

  sysdig_secure_endpoint       = var.sysdig_secure_endpoint
  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name

  build_project_arn  = module.codebuild.project_arn
  build_project_name = module.codebuild.project_name

  sns_topic_arn = module.cloudtrail.sns_topic_arn

  ecs_cluster = module.ecs_fargate_cluster.id
  vpc_id      = module.ecs_fargate_cluster.vpc_id
  vpc_subnets = module.ecs_fargate_cluster.vpc_subnets

  tags = var.tags
  # note. this is required to avoid race conditions
  depends_on = [module.cloudtrail, module.ecs_fargate_cluster, module.codebuild, module.ssm]
}

#-------------------------------------
# cloud-bench
#-------------------------------------
provider "sysdig" {
  sysdig_secure_url          = var.sysdig_secure_endpoint
  sysdig_secure_api_token    = var.sysdig_secure_api_token
  sysdig_secure_insecure_tls = length(regexall("https://.*?\\.sysdig(cloud)?.com/?", var.sysdig_secure_endpoint)) == 1 ? false : true
}

module "cloud_bench" {
  source = "../../modules/services/cloud-bench"

  name              = "${var.name}-cloudbench"
  tags              = var.tags
  benchmark_regions = var.benchmark_regions
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "member"
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::${var.sysdig_secure_for_cloud_member_account_id}:role/${var.organizational_member_default_admin_role}"
  }
}

provider "sysdig" {
  sysdig_secure_url          = var.sysdig_secure_endpoint
  sysdig_secure_api_token    = var.sysdig_secure_api_token
  sysdig_secure_insecure_tls = length(regexall("https://.*?\\.sysdig(cloud)?.com/?", var.sysdig_secure_endpoint)) == 1 ? false : true
}

#-------------------------------------
# resources deployed always in management account
# with default provider
#-------------------------------------

module "resource_group" {
  source = "../../modules/infrastructure/resource-group"
  name   = var.name
  tags   = var.tags
}

module "cloudtrail" {
  source = "../../modules/infrastructure/cloudtrail"
  name   = var.name

  is_organizational = true
  organizational_config = {
    sysdig_secure_for_cloud_member_account_id = var.sysdig_secure_for_cloud_member_account_id
    organizational_role_per_account           = var.organizational_member_default_admin_role
  }

  is_multi_region_trail = var.cloudtrail_is_multi_region_trail
  cloudtrail_kms_enable = var.cloudtrail_kms_enable

  tags = var.tags
}


#-------------------------------------
# secure-for-cloud member account workload
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


#
# cloud-connector
#
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
    sysdig_secure_for_cloud_role_arn = module.secure_for_cloud_role.sysdig_secure_for_cloud_role_arn
    connector_ecs_task_role_name     = aws_iam_role.connector_ecs_task.name
  }

  sns_topic_arn = module.cloudtrail.sns_topic_arn

  ecs_cluster = module.ecs_fargate_cluster.id
  vpc_id      = module.ecs_fargate_cluster.vpc_id
  vpc_subnets = module.ecs_fargate_cluster.vpc_subnets

  tags       = var.tags
  depends_on = [module.cloudtrail, module.ecs_fargate_cluster, module.ssm]
}

#
# cloud-scanning
#
## FIXME? if this is a non-shared resource, move its usage to scanning service?
module "codebuild" {
  providers = {
    aws = aws.member
  }
  source                       = "../../modules/infrastructure/codebuild"
  name                         = var.name
  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name
  depends_on                   = [module.ssm]
}

module "cloud_scanning" {
  providers = {
    aws = aws.member
  }

  source = "../../modules/services/cloud-scanning"
  name   = "${var.name}-cloudscanning"

  sysdig_secure_endpoint       = var.sysdig_secure_endpoint
  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name

  build_project_arn  = module.codebuild.project_arn
  build_project_name = module.codebuild.project_name

  is_organizational = true
  organizational_config = {
    sysdig_secure_for_cloud_role_arn = module.secure_for_cloud_role.sysdig_secure_for_cloud_role_arn
    organizational_role_per_account  = var.organizational_member_default_admin_role
    scanning_ecs_task_role_name      = aws_iam_role.connector_ecs_task.name
  }

  sns_topic_arn = module.cloudtrail.sns_topic_arn

  ecs_cluster = module.ecs_fargate_cluster.id
  vpc_id      = module.ecs_fargate_cluster.vpc_id
  vpc_subnets = module.ecs_fargate_cluster.vpc_subnets

  tags       = var.tags
  depends_on = [module.cloudtrail, module.ecs_fargate_cluster, module.codebuild, module.ssm]
}

#-------------------------------------
# cloud-bench
#-------------------------------------

module "cloud_bench" {
  source = "../../modules/services/cloud-bench"

  name              = "${var.name}-cloudbench"
  tags              = var.tags
  is_organizational = true
  region            = var.region
  benchmark_regions = var.benchmark_regions
}

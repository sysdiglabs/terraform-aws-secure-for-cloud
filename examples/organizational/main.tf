provider "aws" {
  alias = "member"
  # NOTE. this won't work with test, workaround with var
  #  region = data.aws_region.current.name
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


#-------------------------------------
# secure-for-cloud member account workload
#-------------------------------------
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
module "codebuild" {
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

  sysdig_secure_endpoint       = var.sysdig_secure_endpoint
  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name

  build_project_arn  = module.codebuild.project_arn
  build_project_name = module.codebuild.project_name

  is_organizational = true
  organizational_config = {
    sysdig_secure_for_cloud_role_arn = module.secure_for_cloud_role.sysdig_secure_for_cloud_role_arn
    organizational_role_per_account  = var.organizational_member_default_admin_role
    connector_ecs_task_role_name     = aws_iam_role.connector_ecs_task.name
  }

  sns_topic_arn = local.cloudtrail_sns_arn

  ecs_cluster_id     = var.ecs_cluster_id
  ecs_vpc_id         = var.ecs_vpc_id
  ecs_vpc_region_azs = var.ecs_vpc_region_azs
  ecs_sg_id          = var.ecs_sg_id

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

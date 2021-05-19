locals {
  requires_new_ecs_cluster = var.existing_ecs_cluster == "" || var.existing_ecs_cluster_vpc == "" || length(var.existing_ecs_cluster_private_subnets) == 0
  deploy_cloudconnector    = var.cloudconnector_deploy
  deploy_cloudscanning     = var.ecr_image_scanning_deploy || var.ecs_image_scanning_deploy
  deploy_cloudbench        = var.cloudbench_deploy
  deploy_new_ecs_cluster   = local.requires_new_ecs_cluster && (local.deploy_cloudconnector || local.deploy_cloudscanning || local.deploy_cloudbench)
  verify_ssl               = length(regexall("^https://.*?\\.sysdig.com/?", var.sysdig_secure_endpoint)) != 0
  bucket_name              = "${substr(lower(var.naming_prefix), 0, 29)}-config-"
}

resource "aws_s3_bucket" "s3_config_bucket" {
  bucket_prefix = local.bucket_name
  force_destroy = true

  versioning {
    enabled = true
  }
}

resource "aws_ssm_parameter" "secure_api_token" {
  name  = "${var.naming_prefix}-SysdigSecureAPIToken"
  type  = "SecureString"
  value = var.sysdig_secure_api_token
}

resource "aws_ssm_parameter" "secure_endpoint" {
  name  = "${var.naming_prefix}-SysdigSecureEndpoint"
  type  = "SecureString"
  value = var.sysdig_secure_endpoint
}

module "ecs_fargate_cluster" {
  count = local.deploy_new_ecs_cluster ? 1 : 0

  source = "../ecsfargatecluster"

  naming_prefix = var.naming_prefix
}

module "cloud_connector" {
  count = local.deploy_cloudconnector ? 1 : 0

  depends_on = [
    aws_ssm_parameter.secure_endpoint,
    aws_ssm_parameter.secure_api_token,
  ]

  source = "../cloudconnector"

  ecs_cluster          = local.deploy_new_ecs_cluster ? module.ecs_fargate_cluster[0].id : var.existing_ecs_cluster
  vpc                  = local.deploy_new_ecs_cluster ? module.ecs_fargate_cluster[0].vpc_id : var.existing_ecs_cluster_vpc
  subnets              = local.deploy_new_ecs_cluster ? module.ecs_fargate_cluster[0].private_subnets : var.existing_ecs_cluster_private_subnets
  ssm_endpoint         = aws_ssm_parameter.secure_endpoint.name
  ssm_token            = aws_ssm_parameter.secure_api_token.name
  s3_config_bucket     = aws_s3_bucket.s3_config_bucket.id
  verify_ssl           = local.verify_ssl
  accounts_and_regions = var.trail_accounts_and_regions
  naming_prefix        = var.naming_prefix
}

module "cloud_scanning" {
  count = local.deploy_cloudscanning ? 1 : 0

  depends_on = [
    aws_ssm_parameter.secure_endpoint,
    aws_ssm_parameter.secure_api_token,
  ]

  source = "../cloudscanning"

  ecs_cluster          = local.deploy_new_ecs_cluster ? module.ecs_fargate_cluster[0].id : var.existing_ecs_cluster
  vpc                  = local.deploy_new_ecs_cluster ? module.ecs_fargate_cluster[0].vpc_id : var.existing_ecs_cluster_vpc
  subnets              = local.deploy_new_ecs_cluster ? module.ecs_fargate_cluster[0].private_subnets : var.existing_ecs_cluster_private_subnets
  ssm_endpoint         = aws_ssm_parameter.secure_endpoint.name
  ssm_token            = aws_ssm_parameter.secure_api_token.name
  verify_ssl           = local.verify_ssl
  deploy_ecr           = var.ecr_image_scanning_deploy
  deploy_ecs           = var.ecs_image_scanning_deploy
  accounts_and_regions = var.trail_accounts_and_regions
  naming_prefix        = var.naming_prefix
}

module "cloud_bench" {
  count = local.deploy_cloudbench ? 1 : 0

  depends_on = [
    aws_ssm_parameter.secure_endpoint,
    aws_ssm_parameter.secure_api_token,
  ]

  source = "../cloudbench"

  ecs_cluster      = local.deploy_new_ecs_cluster ? module.ecs_fargate_cluster[0].id : var.existing_ecs_cluster
  vpc              = local.deploy_new_ecs_cluster ? module.ecs_fargate_cluster[0].vpc_id : var.existing_ecs_cluster_vpc
  subnets          = local.deploy_new_ecs_cluster ? module.ecs_fargate_cluster[0].private_subnets : var.existing_ecs_cluster_private_subnets
  ssm_endpoint     = aws_ssm_parameter.secure_endpoint.name
  ssm_token        = aws_ssm_parameter.secure_api_token.name
  s3_config_bucket = aws_s3_bucket.s3_config_bucket.id
  verify_ssl       = local.verify_ssl
  accounts         = var.bench_accounts
  naming_prefix    = var.naming_prefix
}

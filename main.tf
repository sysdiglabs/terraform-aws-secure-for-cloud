locals {
  requires_cloudtrail      = var.existing_cloud_trail_sns_topic == ""
  requires_new_ecs_cluster = var.existing_ecs_cluster == "" || var.existing_ecs_cluster_vpc == "" || length(var.existing_ecs_cluster_private_subnets) == 0
  deploy_cloud_scanning    = var.deploy_ecr_scanning || var.deploy_ecs_scanning
  deploy_cloudtrail        = local.requires_cloudtrail && (var.deploy_cloudconnector || local.deploy_cloud_scanning)
  deploy_new_ecs_cluster   = local.requires_new_ecs_cluster && (var.deploy_cloudconnector || local.deploy_cloud_scanning || var.deploy_cloudbench)
  verify_ssl               = length(regexall("https://.*?\\.sysdig.com/?", var.sysdig_secure_endpoint)) == 0
}

resource "aws_s3_bucket" "s3_config_bucket" {
  bucket        = "${var.name}-config-bucket"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
}

resource "aws_ssm_parameter" "secure_api_token" {
  name  = "${var.name}-sysdig-secure-api-token"
  type  = "SecureString"
  value = var.sysdig_secure_api_token
}

resource "aws_ssm_parameter" "secure_endpoint" {
  name  = "${var.name}-sysdig-secure-endpoint"
  type  = "SecureString"
  value = var.sysdig_secure_endpoint
}

module "ecs_fargate_cluster" {
  count  = local.deploy_new_ecs_cluster ? 1 : 0
  source = "./modules/ecscluster"
  name   = "${var.name}-ecscluster"
}

module "cloudtrail" {
  count       = local.deploy_cloudtrail ? 1 : 0
  source      = "./modules/cloudtrail"
  name        = "${var.name}-cloudtrail"
  bucket_name = "${var.name}-cloudtrail"
}

module "cloud_connector" {
  count         = var.deploy_cloudconnector ? 1 : 0
  depends_on    = [module.ecs_fargate_cluster, module.cloudtrail, aws_ssm_parameter.secure_endpoint, aws_ssm_parameter.secure_api_token]
  source        = "./modules/cloudconnector"
  name          = "${var.name}-cloudconnector"
  ecs_cluster   = local.deploy_new_ecs_cluster ? module.ecs_fargate_cluster[0].id : var.existing_ecs_cluster
  vpc           = local.deploy_new_ecs_cluster ? module.ecs_fargate_cluster[0].vpc_id : var.existing_ecs_cluster_vpc
  subnets       = local.deploy_new_ecs_cluster ? module.ecs_fargate_cluster[0].private_subnets : var.existing_ecs_cluster_private_subnets
  ssm_endpoint  = aws_ssm_parameter.secure_endpoint.name
  ssm_token     = aws_ssm_parameter.secure_api_token.name
  config_bucket = aws_s3_bucket.s3_config_bucket.id
  sns_topic_arn = local.deploy_cloudtrail ? module.cloudtrail[0].topic_arn : var.existing_cloud_trail_sns_topic
  verify_ssl    = local.verify_ssl
  //TODO: telemetry?
}

module "scanning_codebuild" {
  count        = local.deploy_cloud_scanning ? 1 : 0
  depends_on   = [aws_ssm_parameter.secure_endpoint, aws_ssm_parameter.secure_api_token]
  source       = "./modules/scanning-codebuild"
  name         = "${var.name}-scanning-codebuild"
  ssm_endpoint = aws_ssm_parameter.secure_endpoint.name
  ssm_token    = aws_ssm_parameter.secure_api_token.name
  verify_ssl   = local.verify_ssl
}

module "cloud_scanning" {
  count             = local.deploy_cloud_scanning ? 1 : 0
  depends_on        = [module.ecs_fargate_cluster, module.cloudtrail, module.scanning_codebuild, aws_ssm_parameter.secure_endpoint, aws_ssm_parameter.secure_api_token]
  source            = "./modules/cloudscanning"
  name              = "${var.name}-cloudscanning"
  ecs_cluster       = local.deploy_new_ecs_cluster ? module.ecs_fargate_cluster[0].id : var.existing_ecs_cluster
  vpc               = local.deploy_new_ecs_cluster ? module.ecs_fargate_cluster[0].vpc_id : var.existing_ecs_cluster_vpc
  subnets           = local.deploy_new_ecs_cluster ? module.ecs_fargate_cluster[0].private_subnets : var.existing_ecs_cluster_private_subnets
  ssm_endpoint      = aws_ssm_parameter.secure_endpoint.name
  ssm_token         = aws_ssm_parameter.secure_api_token.name
  sns_topic_arn     = local.deploy_cloudtrail ? module.cloudtrail[0].topic_arn : var.existing_cloud_trail_sns_topic
  deploy_ecr        = var.deploy_ecr_scanning
  deploy_ecs        = var.deploy_ecs_scanning
  codebuild_project = module.scanning_codebuild[0].project_id
  verify_ssl        = local.verify_ssl
}

module "cloud_bench" {
  count         = var.deploy_cloudbench ? 1 : 0
  depends_on    = [module.ecs_fargate_cluster, aws_ssm_parameter.secure_endpoint, aws_ssm_parameter.secure_api_token]
  source        = "./modules/cloudbench"
  name          = "${var.name}-cloudbench"
  ecs_cluster   = local.deploy_new_ecs_cluster ? module.ecs_fargate_cluster[0].id : var.existing_ecs_cluster
  vpc           = local.deploy_new_ecs_cluster ? module.ecs_fargate_cluster[0].vpc_id : var.existing_ecs_cluster_vpc
  subnets       = local.deploy_new_ecs_cluster ? module.ecs_fargate_cluster[0].private_subnets : var.existing_ecs_cluster_private_subnets
  ssm_endpoint  = aws_ssm_parameter.secure_endpoint.name
  ssm_token     = aws_ssm_parameter.secure_api_token.name
  config_bucket = aws_s3_bucket.s3_config_bucket.id
  verify_ssl    = local.verify_ssl
}

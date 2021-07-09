provider "aws" {
}


##########################
# common
##########################
locals {
  verify_ssl = length(regexall("https://.*?\\.sysdig(cloud)?.com/?", var.sysdig_secure_endpoint)) == 1
}

resource "aws_ssm_parameter" "secure_endpoint" {
  name  = "${var.name}-sysdig-secure-endpoint"
  type  = "SecureString"
  value = var.sysdig_secure_endpoint
}

resource "aws_ssm_parameter" "secure_api_token" {
  name  = "${var.name}-sysdig-secure-api-token"
  type  = "SecureString"
  value = var.sysdig_secure_api_token
}

resource "aws_s3_bucket" "s3_config_bucket" {
  bucket        = "${var.name}-config"
  acl           = "private"
  force_destroy = true
  versioning {
    enabled = true
  }
}

module "ecs_fargate_cluster" {
  name   = "${var.name}-ecscluster"
  source = "./modules/ecscluster"
}




##########################
# modules
##########################
module "cloudtrail_organizational" {
  source = "./modules/organizational/cloudtrail"

  cloudtrail_name = "${var.name}-cloudtrail-org"
  s3_bucket_name  = "${var.name}-cloudtrail-org"
}


module "cloud_connector" {
  source = "./modules/cloudconnector"

  name         = "${var.name}-cloudconnector"
  ssm_endpoint = aws_ssm_parameter.secure_endpoint.name
  ssm_token    = aws_ssm_parameter.secure_api_token.name

  sns_topic_arn = module.cloudtrail_organizational.sns_topic_arn
  config_bucket = aws_s3_bucket.s3_config_bucket.id

  ecs_cluster = module.ecs_fargate_cluster.id
  vpc         = module.ecs_fargate_cluster.vpc_id
  subnets     = module.ecs_fargate_cluster.private_subnets

  verify_ssl = local.verify_ssl

  depends_on = [aws_ssm_parameter.secure_endpoint, aws_ssm_parameter.secure_api_token] # requires explicit aws_ssm dependency
}

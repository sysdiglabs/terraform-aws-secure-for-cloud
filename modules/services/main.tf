#----------------------------
# cloud_services common resources
#----------------------------
locals {
  verify_ssl = var.verify_ssl == "auto" ? length(regexall("https://.*?\\.sysdig(cloud)?.com/?", var.sysdig_secure_endpoint)) == 1 : var.verify_ssl == "true"
}

resource "aws_ssm_parameter" "secure_endpoint" {
  name  = "${var.name}-sysdig-secure-endpoint"
  type  = "SecureString"
  value = var.sysdig_secure_endpoint
  tags  = var.tags
}

resource "aws_ssm_parameter" "secure_api_token" {
  name  = "${var.name}-sysdig-secure-api-token"
  type  = "SecureString"
  value = var.sysdig_secure_api_token
  tags  = var.tags
}




#----------------------------
# modules
#----------------------------

module "ecs_fargate_cluster" {
  name   = "${var.name}-ecscluster"
  source = "../services_ecscluster"
  tags   = var.tags
}


module "cloud_connector" {
  source = "../services_cloud_connect"

  name         = "${var.name}-cloudconnector"
  ssm_endpoint = aws_ssm_parameter.secure_endpoint.name
  ssm_token    = aws_ssm_parameter.secure_api_token.name

  sns_topic_arn            = var.cloudtrail_sns_topic_arn
  services_assume_role_arn = var.services_assume_role_arn
  config_bucket            = aws_s3_bucket.s3_config_bucket.id

  ecs_cluster = module.ecs_fargate_cluster.id
  vpc         = module.vpc.vpc_id
  subnets     = module.vpc.private_subnets

  verify_ssl = local.verify_ssl

  tags = var.tags

  # requires explicit aws_ssm dependency
  depends_on = [aws_ssm_parameter.secure_endpoint, aws_ssm_parameter.secure_api_token]
}

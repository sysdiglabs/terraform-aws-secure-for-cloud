data "aws_ssm_parameter" "endpoint" {
  name = var.ssm_endpoint
}

data "aws_ssm_parameter" "api_token" {
  name = var.ssm_token
}

data "aws_caller_identity" "me" {}
data "aws_region" "current" {}

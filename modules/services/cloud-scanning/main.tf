data "aws_region" "current" {}

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
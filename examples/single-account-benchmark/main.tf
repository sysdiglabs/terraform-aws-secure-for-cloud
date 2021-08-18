provider "aws" {
  region = var.region
}

# FIXME. refact verify_ssl so its handled in upper layers and passed downwards
locals {
  verify_ssl = length(regexall("https://.*?\\.sysdig(cloud)?.com/?", var.sysdig_secure_endpoint)) == 1 ? false : true
}

provider "sysdig" {
  sysdig_secure_url          = var.sysdig_secure_endpoint
  sysdig_secure_api_token    = var.sysdig_secure_api_token
  sysdig_secure_insecure_tls = local.verify_ssl
}


data "aws_caller_identity" "me" {}

module "cloud_bench" {
  source = "../../modules/services/cloud-bench"

  account_id = data.aws_caller_identity.me.account_id
  tags       = var.tags
}

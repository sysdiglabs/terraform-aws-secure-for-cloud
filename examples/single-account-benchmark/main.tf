provider "aws" {
  region = var.region
}

provider "sysdig" {
  sysdig_secure_url          = var.sysdig_secure_endpoint
  sysdig_secure_api_token    = var.sysdig_secure_api_token
  sysdig_secure_insecure_tls = length(regexall("https://.*?\\.sysdig(cloud)?.com/?", var.sysdig_secure_endpoint)) == 1 ? false : true
}


data "aws_caller_identity" "me" {}

module "cloud_bench" {
  source = "../../modules/services/cloud-bench"

  account_id = data.aws_caller_identity.me.account_id
  tags       = var.tags
}

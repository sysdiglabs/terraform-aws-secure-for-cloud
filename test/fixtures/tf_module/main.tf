provider "aws" {}
module "cloudvision_aws_single_account" {
  source = "../../../examples-internal/single-account-without-bench"

  sysdig_secure_api_token = var.sysdig_secure_api_token
  sysdig_secure_endpoint  = var.sysdig_secure_endpoint
  name                    = var.name
  region                  = var.region
}

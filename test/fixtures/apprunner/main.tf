terraform {
  required_providers {
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = ">=0.5.33"
    }
  }
}

provider "sysdig" {
  sysdig_secure_api_token = var.sysdig_secure_api_token
  sysdig_secure_url       = var.sysdig_secure_url
}

provider "aws" {
  region = var.region
}

module "cloudvision_aws_single_account" {
  source = "../../../examples/apprunner"
  name   = "${var.name}-apprunner"
  # TODO Refactor to reference this variable only once
  sysdig_secure_api_token = var.sysdig_secure_api_token
}

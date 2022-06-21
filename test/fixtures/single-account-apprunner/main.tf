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
  region = "eu-west-1"
}

module "cloudvision_aws_apprunner_single_account" {
  source = "../../../examples/single-account-apprunner"
  name   = var.name

  deploy_image_scanning_ecr = true
  deploy_image_scanning_ecs = true
  use_standalone_scanner = false
}

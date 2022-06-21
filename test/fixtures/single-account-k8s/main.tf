terraform {
  required_providers {
    sysdig = {
      source = "sysdiglabs/sysdig"
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

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "cloudvision_aws_single_account_k8s" {
  source = "../../../examples/single-account-k8s"
  name   = "${var.name}-singlek8s"

  deploy_image_scanning_ecr = true
  deploy_image_scanning_ecs = true
  use_standalone_scanner    = false
}

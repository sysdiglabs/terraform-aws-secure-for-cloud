terraform {
  required_version = ">= 0.15.0"
  required_providers {
    aws = {
      version = ">= 3.50.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.3.0"
    }
  }
}

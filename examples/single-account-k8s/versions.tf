terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      version = ">= 3.50.0"
    }
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = ">= 0.5.33"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.3.0"
    }
  }
}

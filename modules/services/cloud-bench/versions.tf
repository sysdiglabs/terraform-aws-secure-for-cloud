terraform {
  required_version = ">= 0.15.0"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }

    aws = {
      version = ">= 3.62.0"
    }
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = ">= 0.5.29"
    }
  }
}

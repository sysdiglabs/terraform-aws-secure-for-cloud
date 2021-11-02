terraform {
  required_version = ">= 0.15.0"
  required_providers {
    aws = {
      version = ">= 3.62.0"
    }
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = ">= 0.5.21"
    }
  }
}

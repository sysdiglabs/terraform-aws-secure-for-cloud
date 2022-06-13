terraform {
  required_version = ">= 0.15.0"
  required_providers {
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = ">= 0.5.33"
    }
  }
}

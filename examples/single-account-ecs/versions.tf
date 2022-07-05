terraform {
  required_version = ">= 1.0.0"
  required_providers {
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = ">= 0.5.33"
    }
  }
}

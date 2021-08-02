terraform {
  required_providers {
    aws = {
      version = ">= 3.50.0"
    }
    sysdig = {
      source = "registry.terraform.io/sysdiglabs/sysdig"
      version = "0.5.17" // TODO release updated sysdig provider
    }
  }
}

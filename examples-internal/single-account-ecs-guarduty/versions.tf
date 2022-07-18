terraform {
  required_version = ">= 1.0.0"
  required_providers {
    # tflint-ignore: terraform_unused_required_providers
    aws = {
      version = ">= 4.0.0"
    }
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = ">= 0.5.33"
    }
  }
}

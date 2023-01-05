# SingleAccount-CIS Benchmarks

## Use-Case explanation

Simple single-account setup, in order to get [CIS Unified Compliance Benchmarks](https://docs.sysdig.com/en/docs/sysdig-secure/posture/compliance/compliance-unified-/)

## Setup

```terraform
terraform {
  required_providers {
    sysdig = {
      source  = "sysdiglabs/sysdig"
    }
  }
}

provider "sysdig" {
  sysdig_secure_url        = "<SYSDIG_SECURE_URL>"
  sysdig_secure_api_token  = "<SYSDIG_SECURE_API_TOKEN>"
}

provider "aws" {
  region = "<AWS_REGION>"
}

module "sysdig-sfc" {
  source = "sysdiglabs/secure-for-cloud/aws//module/services/cloud-bench"
  name    = "sysdig-compliance-role"  # optional
}
```

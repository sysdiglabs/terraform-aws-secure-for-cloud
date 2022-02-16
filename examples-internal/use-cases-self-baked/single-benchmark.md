# SingleAccount-Benchmark

## Use-Case explanation

Simple single-account benchmark

**Client Setup**

- [X] single-account setup
- [ ] pre-existing resources

**Sysdig Secure For Cloud Features**

- [X] CSPM/Compliance (WIP?)

## Suggested setup

```terraform
terraform {
  required_providers {
    sysdig = {
      source  = "sysdiglabs/sysdig"
    }
  }
}

provider "sysdig" {
  sysdig_secure_api_token = "<SYSDIG_API_TOKEN>"
}

provider "aws" {
  region = "<AWS_REGION>"
}

module "sysdig-s4c" {
  source = "sysdiglabs/secure-for-cloud/aws//module/services/cloud-bench"
  name    = "TEST-NAME-cloudbench"
}
```

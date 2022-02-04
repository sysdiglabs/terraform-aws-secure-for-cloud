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
provider "aws" {
  region = "<AWS_REGION>"
}

module "sysdig-s4c" {
  source = "sysdiglabs/secure-for-cloud/aws//modules/cloud-bench"
  name              = "TEST-NAME-cloudbench"
}
```

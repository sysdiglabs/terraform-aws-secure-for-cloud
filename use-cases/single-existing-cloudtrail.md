# Single Account with Cloudtrail

## Overview

### User Setup

- [X] Single Account setup
- [X] Pre-existing resources
  - [X] CloudTrail
  - [ ] Kubernetes cluster to deploy Sysdig for Cloud workload
  - [ ] ECS cluster with VPC/subnet for the Sysdig for Cloud deployment

### Sysdig Secure For Cloud Features

- [X] Threat Detection
  - [X] all accounts of the organization (management account included)
- [ ] Image Scanning (WIP?)
  - [ ] ECR pushed images
  - [ ] ECS running images
- [ ] CSPM/Compliance (WIP?)
- [ ] CIEM (WIP?)

## Preparation

For this use case, you will use the [`./examples/single-account-ecs`](./examples/single-account-ecs/README.md) setup. In order for this setup to work, several roles and permissions are required. Before proceeding, see the [readme](./examples/single-account-ecs/README.md)  and check whether you comply with the requirements.

Contact Sysdig for support.

## Installation

Use the [`single-account`](./examples/single-account-ecs/README.md) example with the `cloudtrail_sns_arn` parameter:

<!--
manual testing pre-requirements

0.1 Cloudtrail must exist. To be deployed on a separated terraform state

```
provider "aws" {
region = var.region
}

module "utils_cloudtrail" {
  source = "sysdiglabs/secure-for-cloud/aws//modules/infrastructure/cloudtrail"
  name   = "cloudtrail-test"
}
```

If cloudtrail is in another account
 {
      "Sid": "AllowCrossAccountSNSSubscription,
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::account-member:user/<SPECIFIC_USER>"
        # or
        #"AWS": "arn:aws:iam::account-member:root"
      },
      "Action": "sns:Subscribe",
      "Resource": "<CLOUDTRAIL_SNS_ARN>"
    }

-->

```terraform
terraform {
  required_providers {
    sysdig = {
      source  = "sysdiglabs/sysdig"
    }
  }
}

provider "sysdig" {
  sysdig_secure_url         = "<SYSDIG_SECURE_URL>"
  sysdig_secure_api_token   = "<SYSDIG_SECURE_API_TOKEN>"
}

provider "aws" {
  region = "<AWS_REGION>"
}

module "sysdig-sfc" {
  source = "sysdiglabs/secure-for-cloud/aws//examples/single-account-ecs"
  name   = "sysdig-sfc"

  cloudtrail_sns_arn  = "<CLOUDRAIL_SNS_TOPIC_ARN>"
}
```

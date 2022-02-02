# SingleAccount - Existing Cloudtrail

## Use-Case explanation

**Client Setup**

- [X] single-account setup
- [X] pre-existing resources
  - [X] cloudtrail
  - [ ] k8s cluster we want to use to deploy Sysdig for Cloud workload
  - [ ] pre-existing ECS Cluster/VPC/Subnet we want to use to deploy Sysdig for Cloud workload

**Sysdig Secure For Cloud Features**

- [X] Threat Detection
  - [X] all accounts of the organization (management account included)
- [ ] Image Scanning (WIP?)
  - [ ] ECR pushed images
  - [ ] ECS running images
- [ ] CSPM/Compliance (WIP?)
- [ ] CIEM (WIP?)

## Suggested setup

<!--
testing

0. ECS/Subnet/VPC should exist, otherwise deploy this items first on a sepparated terraform state

```terraform
provider "aws" {
region = var.region
}

module "utils_cloudtrail" {
  source = "sysdiglabs/secure-for-cloud/aws//modules/infrastructure/cloudtrail"
  name   = "${var.name}-single-provide-cloudtrail"
}
```
-->

1. Refine **Permissions**

Check whether terraform aws provider `AWS_PROFILE` is able to perform an `SNS:Subscribe` action on the existing cloudtrail.

<!--
 {
      "Sid": "AllowCrossAccountSNSSubscription,
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::account-member:user/<SPECIFC_USER>"
        # or
        #"AWS": "arn:aws:iam::account-member:root"
      },
      "Action": "sns:Subscribe",
      "Resource": "<CLOUDTRAIL_SNS_ARN>"
    }
-->

2. Use `single-account` example with **`cloudtrail_sns_arn` parameter**

```terraform`
provider "aws" {
  region = <AWS_REGION>
}

module "sysdig-s4c" {
  source = "sysdiglabs/secure-for-cloud/aws//examples/single-account"
  name   = "sysdig-s4c"

  sysdig_secure_api_token = <SYSDIG_API_TOKEN>
  cloudtrail_sns_arn      = <CLOUDRAIL_SNS_TOPIC_ARN>
}
``

<!--
testing
```
cloudtrail_sns_arn      = module.utils_cloudtrail.sns_topic_arn
```
-->

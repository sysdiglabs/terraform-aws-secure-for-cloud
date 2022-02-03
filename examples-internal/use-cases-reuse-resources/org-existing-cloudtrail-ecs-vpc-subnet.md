# OrganizationSetup - Existing Cloudtrail - Existing ECS/VPC/Subnet

## Use-Case explanation

**Client Setup**

- [X] organizational setup
  - [X] organizational cloudtrail
  - [X] centralized S3 bucket with cloudtrail-events
  - [X] member account usage - all required resources (cloudtrail/s3/sns/sqs for sysdig workload) in same account (managed or specific) (?)
  - [ ] member account usage - all required resources are in scattered
- [X] pre-existing resources
  - [ ] k8s cluster we want to use to deploy Sysdig for Cloud workload
  - [X] pre-existing ECS Cluster/VPC/Subnet we want to use to deploy Sysdig for Cloud workload

**Sysdig Secure For Cloud Features**

- [X] Threat Detection
  - [X] all accounts of the organization (management account included)
- [ ] Image Scanning (?)
  - [ ] ECR pushed images
  - [ ] ECS running images
- [ ] CSPM/Compliance (?)
- [ ] CIEM (?)




## Suggested setup

<!--
testing

0. Cloudtrail should exist, otherwise deploy this items first on a sepparated terraform state

```terraform
provider "aws" {
region = var.region
}

module "utils_ecs-vpc-secgroup" {
  source = "../../modules/infrastructure/ecs-vpc-secgroup"
}
```
-->

0. Configure `AWS_PROFILE` with an organizational Administration credentials

1. Choose an Organizational **Member account for Sysdig Workload** to be deployed. This accountID will be provided in the `sysdig_secure_for_cloud_member_account_id` parameter

3. Use `organizational` example with following parameters

Existing Cloudtrail Setup
  - `cloudtrail_sns_arn`
  - `cloudtrail_s3_arn`

Existing ECS Cluster Workload  Setup
  - `ecs_cluster_name` ex.: "sfc"

Existing Networking Setup
  - `ecs_vpc_id` ex.: "vpc-0e91bfef6693f296b"
  - `ecs_vpc_subnets_private` Two subnets for the VPC. ex.: "subnet-0c7d803ecdc88437b"

```terraform
provider "aws" {
  region = "<AWS_REGION>"
}

module "sysdig-s4c" {
  source = "sysdiglabs/secure-for-cloud/aws//examples/organizational"
  name   = "sysdig-s4c"

  sysdig_secure_for_cloud_member_account_id="<AWS_ACCOUNT_ID>"

  sysdig_secure_api_token = "<SYSDIG_API_TOKEN>"

  cloudtrail_sns_arn      = "<CLOUDRAIL_SNS_TOPIC_ARN>"
  cloudtrail_s3_arn      = "<CLOUDRAIL_S3_BUCKET_ARN>"

  ecs_cluster_name="<ECS_CLUSTER_NAME>"

  ecs_vpc_id="<VPC_ID"
  ecs_vpc_subnets_private=["<SUBNET_ID_1>","<SUBNET_ID_2>"]

}
```

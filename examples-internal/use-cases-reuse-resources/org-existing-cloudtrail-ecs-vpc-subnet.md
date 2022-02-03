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

For this use-case we're going to use the [`./examples/organizational`](../../examples/organizational/README.md) setup.
In order for this setup to work, several roles and permissions are required.
Before proceeding, please read the example README and check whether you comply with requirements.

Please contact us if something requires to be adjusted.


### Step by Step Example Guide


<!--
manual testing pre-requirements

0.1 Cloudtrail must exist. To be deployed on a separated terraform state

```
provider "aws" {
	region = "eu-west-3"
}

module "utils_cloudtrail" {
  source = "../../../modules/infrastructure/cloudtrail"
  name   = "cloudtrail-test"

  is_organizational=true
  organizational_config = {
    sysdig_secure_for_cloud_member_account_id = "42******61"
    organizational_role_per_account  = "OrganizationAccountAccessRole"
  }
}
```

0.2. ECS/VPC/Subnet must exist. To be deployed on a separated terraform state

```
provider "aws" {
region = "eu-west-3"
}

module "utils_ecs-vpc-secgroup" {
  source = "../../modules/infrastructure/ecs-vpc-secgroup"
}
```
-->

0. Configure `AWS_PROFILE` with an organizational Administration credentials

1. Choose an Organizational **Member account for Sysdig Workload** to be deployed. This accountID will be provided in the `sysdig_secure_for_cloud_member_account_id` parameter

2. Use `organizational` example with following parameters

   - General
     - `AWS_REGION` Same region is to be used for all the following resources, both on the organizational managed account and sysdig workload member account

   - Existing Organizational Cloudtrail Setup
     - `cloudtrail_sns_arn`
     - `cloudtrail_s3_arn`
     - You MUST grant manual permissions to the organizational cloudtrail, for the `` ARN to be able to perform `SNS:Subscribe`. This will be required for the CloudConnector SQS Topic.

   - Existing ECS Cluster Workload  Setup
     - `ecs_cluster_name` ex.: "sfc"

   - Existing Networking Setup
     - `ecs_vpc_id` ex.: "vpc-0e91bfef6693f296b"
     - `ecs_vpc_subnets_private` Two subnets for the VPC. ex.: "subnet-0c7d803ecdc88437b"


### Terraform Manifest Snippet

```terraform
provider "aws" {
  region = "<AWS_REGION>"
}

module "sysdig-s4c" {

  source = "sysdiglabs/secure-for-cloud/aws//examples/organizational"
  name   = "sysdig-s4c"

  sysdig_secure_for_cloud_member_account_id="<AWS_ACCOUNT_ID>"

  sysdig_secure_api_token   = "<SYSDIG_API_TOKEN>"

  cloudtrail_sns_arn        = "<CLOUDRAIL_SNS_TOPIC_ARN>"
  cloudtrail_s3_arn         = "<CLOUDRAIL_S3_BUCKET_ARN>"

  ecs_cluster_name          = "<ECS_CLUSTER_NAME>"
  ecs_vpc_id                = "<VPC_ID>"
  ecs_vpc_subnets_private   = ["<SUBNET_ID_1>","<SUBNET_ID_2>"]

}
```

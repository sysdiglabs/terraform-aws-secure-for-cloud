# AWS Organizational Setup with Cloudtrail

## Overview

**User Setup**

- [X] AWS organizational account
  - [X] Organizational Cloudtrail that reports to SNS and persists events in a managed-account S3 bucket
  - [X] Member account usage: All the required and pre-existing resources exist in the same account
    - Cloudtrail, SNS, and S3 in the Management account
    - Pre-existing objects in the same account where Sysdig Secure for Cloud workload is to be deployed
  - [ ] Member account usage: All the required resources reside in different member accounts
- [X] Pre-existing resources
  - [X] Organizational cloudtrail reporting to an SNS topic and delivering events to the S3 bucket
  - [X] ECS cluster with VPC and subnet to deploy Sysdig for Cloud workload
  - [ ] Kubernetes cluster to deploy Sysdig for Cloud workload

**Sysdig Secure For Cloud Features**

- [X] Threat Detection
  - [X] all accounts of the organization, including the Management account
- [ ] image Scanning (?)
  - [ ] ECR pushed images
  - [ ] ECS running images
- [ ] CSPM/Compliance (?)
- [ ] CIEM (?)




## Preparation

For this usecase, you will use the [`./examples/organizational`](../examples/organizational/README.md) setup. In order for this setup to work, several roles and permissions are required. Before proceeding, see the [readme](../examples/organizational/README.md)  and check whether you comply with the requirements.

Contact Sysdig for support.


### Step by Step Example Guide

<!--
manual testing pre-requirements

0.1 Cloudtrail must exist. To be deployed on a separated terraform state

```
# AWS_PROFILE must point to organizatinal management account
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
# AWS_PROFILE must point to org member account where workload is to be deployed
provider "aws" {
region = "eu-west-3"
}

module "utils_ecs-vpc" {
  source = "../../modules/infrastructure/ecs-vpc"
}
```
-->

1. Configure `AWS_PROFILE` with an organizational administration credentials.

2. Choose an Organizational member account for Sysdig Workload to be deployed.
   - Note the account ID of this account. This value will be provided in the `SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID` parameter.
   - Workload resources (ECS, VPC, subnets) must be created in this member account.

3. Use the  `organizational` example snippet with following parameters:

   - General
     - `AWS_REGION` : Same region is to be used for both organizational managed account and Sysdig workload member account resources.
     - `SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID`:  where Sysdig Workload is to be deployed under the pre-existing ECS

   - Existing Organizational Cloudtrail Setup
     - `CLOUDTRAIL_SNS_ARN`
     - `CLOUDTRAIL_S3_ARN`
     - You MUST grant manual permissions to the organizational cloudtrail, for the AWS member-account management role `OrganizationAccountAccessRole` to be able to perform `SNS:Subscribe`.
       - This will be required for the CloudConnector SQS Topic subscription.
       - Use [`./modules/infrastructure/cloudtrail/sns_permissions.tf`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/modules/infrastructure/cloudtrail/sns_permissions.tf#L22) as guideline

   - Existing **ECS Cluster and networking** setup
     - Create an ECS cluster and configure it with the existing VPC/Subnet/... network configuration suiting your needs.
     <br/>Refer to [Sysdig SASS Region and IP Ranges Documentation](https://docs.sysdig.com/en/docs/administration/saas-regions-and-ip-ranges/) to get Sysdig SaaS endpoint and allow both outbound (for compute vulnerability report) and inbound (for scheduled compliance checkups)
     <br/>ECS type deployment will create following [security-group setup](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/modules/services/cloud-connector-ecs/sec-group.tf)
     - `ECS_CLUSTER_NAME` ex.: "sfc"
     - `ECS_VPC_ID` ex.: "vpc-0e91bfef6693f296b"
     - `ECS_VPC_SUBNET_PRIVATE_ID_X` Two subnets for the VPC. ex.: "subnet-0c7d803ecdc88437b"<br/><br/>


### Terraform Manifest Snippet

```terraform
terraform {
  required_providers {
    sysdig = {
      source  = "sysdiglabs/sysdig"
      configuration_aliases = [aws.member]
    }
  }
}

provider "sysdig" {
  sysdig_secure_url         = "<SYSDIG_SECURE_URL>"
  sysdig_secure_api_token   = "<SYSDIG_SECURE_API_TOKEN>"
}

provider "aws" {
  region = "<AWS_REGION>"   # must match s3 AND sns region
}

# you can setup this provider as desired, just giving an example
provider "aws" {
  alias  = "member"
  region = "<AWS_REGION>"   # must match s3 AND sns region
  assume_role {
    # 'OrganizationAccountAccessRole' is the default role created by AWS for management-account users to be able to admin member accounts.
    # <br/>https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_access.html
    role_arn = "arn:aws:iam::<SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID>:role/OrganizationAccountAccessRole"
  }
}

module "sysdig-sfc" {
  providers = {
    aws.member = aws.member
  }

  source = "sysdiglabs/secure-for-cloud/aws//examples/organizational"
  name   = "sysdig-sfc"

  sysdig_secure_for_cloud_member_account_id="<SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID>"

  cloudtrail_sns_arn  = "<CLOUDTRAIL_SNS_ARN>"
  cloudtrail_s3_arn   = "<CLOUDTRAIL_S3_ARN>"

  ecs_cluster_name              = "<ECS_CLUSTER_NAME>"
  ecs_vpc_id                    = "<ECS_VPC_ID>"
  ecs_vpc_subnets_private_ids   = ["<ECS_VPC_SUBNET_PRIVATE_ID_1>","<ECS_VPC_SUBNET_PRIVATE_ID_2>"]

}
```

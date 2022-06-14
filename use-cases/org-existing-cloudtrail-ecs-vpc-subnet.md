# OrganizationSetup - Existing Cloudtrail - Existing ECS/VPC/Subnet

## Use-Case explanation

**Client Setup**

- [X] organizational setup
  - [X] organizational cloudtrail that reports to SNS and persists events in a managed-account stored S3 bucket
  - [X] member account usage - all required and pre-existing resources exist in the same account
    - cloudtrail/sns/s3 in the management account
    - and pre-existing objects in the same account where Sysdig Secure for Cloud workload is to be deployed
  - [ ] member account usage - all required resources are in scattered organizational member accounts
- [X] pre-existing resources
  - [X] organizational cloudtrail, reporting to an SNS topic and delivering events to the S3 bucket
  - [X] ecs cluster/vpc/subnet we want to use to deploy Sysdig for Cloud workload
  - [ ] k8s cluster we want to use to deploy Sysdig for Cloud workload

**Sysdig Secure For Cloud Features**

- [X] threat Detection
  - [X] all accounts of the organization (management account included)
- [ ] image Scanning (?)
  - [ ] ecr pushed images
  - [ ] ecs running images
- [ ] CSPM/Compliance (?)
- [ ] CIEM (?)




## Suggested setup

For this use-case we're going to use the [`./examples/organizational`](../examples/organizational/README.md) setup.
In order for this setup to work, several roles and permissions are required.
Before proceeding, please read the example README and check whether you comply with requirements.

Please contact us if something requires to be adjusted.


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

1. Configure `AWS_PROFILE` with an organizational Administration credentials

2. Choose an Organizational **Member account for Sysdig Workload** to be deployed.
   - This accountID will be provided in the `SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID` parameter
   - Use-case workload-related pre-existing resources (ecs,vpc,subnets) must live within this member account

3. Use `organizational` example snippet with following parameters

   - General
     - `AWS_REGION` Same region is to be used for both organizational managed account and Sysdig workload member account resources.
     - `SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID` where Sysdig Workload is to be deployed under the pre-existing ECS

   - Existing Organizational Cloudtrail Setup
     - `CLOUDTRAIL_SNS_ARN`
     - `CLOUDTRAIL_S3_ARN`
     - You MUST grant manual permissions to the organizational cloudtrail, for the AWS member-account management role `OrganizationAccountAccessRole` to be able to perform `SNS:Subscribe`.
       - This will be required for the CloudConnector SQS Topic subscription.
       - Use [`./modules/infrastructure/cloudtrail/sns_permissions.tf`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/modules/infrastructure/cloudtrail/sns_permissions.tf#L22) as guideline

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
  region = "<AWS_REGION>"       # must match s3 AND sns region
}

# you can setup this provider as desired, just giving an example
provider "aws" {
  alias  = "member"
  region = "<AWS_REGION>"       # must match s3 AND sns region
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
}
```

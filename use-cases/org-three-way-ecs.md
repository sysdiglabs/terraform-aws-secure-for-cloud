# Organizational Setup: Three-Way Accounts and ECS

## Overview

This use case covers securing a multi-account AWS environment with workload on ECS, typically created with the [AWS ControlTower landing zone](https://aws.amazon.com/controltower/features/).

The guidelines are terraform-based. For instruction on setting up Secure for Cloud manually, see [Manual Organizational Setup - Three-Way Cross-Account](./manual-org-three-way.md).

### User Setup

- One or more Management Accounts with one of the following:
  - Organizational CloudTrail reporting to the Log Archive Account
  - Several accounts reporting to the same Log Archive Account

- Log Archive Account
  - CloudTrail-enabled S3 bucket with event notification to an SNS-SQS setup
    Note: You can use single account as the Log Archive Account and the Member Account for the Sysdig for Secure workload

- Member Account for the workload
  - Sysdig Secure for Cloud deployment
  - Optionally, re-use an existing VPC/subnet network setup

### Sysdig Secure For Cloud Features

This use case provides the following [Sysdig Secure For Cloud](https://docs.sysdig.com/en/docs/sysdig-secure/sysdig-secure-for-cloud/#features) features:

- [Threat Detection](https://docs.sysdig.com/en/docs/sysdig-secure/policies/threat-detect-policies/)
- [Posture](https://docs.sysdig.com/en/docs/sysdig-secure/posture/)
- [Compliance](https://docs.sysdig.com/en/docs/sysdig-secure/posture/compliance/)
- [Identity Access Management](https://docs.sysdig.com/en/docs/sysdig-secure/posture/identity-and-access/)

:warning: Cloud image scanning is not supported in this use case.

### Guidelines

- Ensure that all the existing resources are within same AWS region:
  - CloudTrail-enabled S3
  - CloudTrail-S3-SNS-SQS setup
  - Sysdig Secure for Cloud workload

- Set up IAM roles to access cross-account resources.

- Optionally, for existing VPC/subnet usage, use the optional variables. An ECS cluster is required to configure these two fields.

- Use the default [organizational example](./examples/organizational/README.md). This example gives instructions to work with managed account-level resources (CloudTrail, S3, SNS, and SQS)
- Use an alternative event ingestion vía S3 event notification with a SNS-SQS forwarder

## Set Up Sysdig Secure for Cloud

<!--

all in same region
management account - cloudtrail (no kms for quick test)
log archive account - s3, sns, sqs

0.1 Provision an S3 bucket in the selected region and allow cloudtrail access
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Statement1",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "S3_ARN/*"
        },
        {
            "Sid": "Statement2",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "S3_ARN"
        }
    ]
}

0.2. Provision the s3 bucket sns event notification. Need to add permissions to SNS
{
      "Sid": "AllowS3ToPublishSNS",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": [
        "SNS:Publish"
      ],
      "Resource": "S3_ARN"
    }
-->

### Configure AWS_PROFILE with an Organizational Administration Credentials

Sysdig Secure for Cloud will create resources both on your management and member accounts. See the following for more information:

- [General Permissions](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud#required-permissions)
- [Organizational Role Summary](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/organizational#role-summary) for this specific scenario

### Choose an Organizational Member Account to Deploy the Sysdig Workload

Save the `accountID` for later use in the `SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID` parameter.

### Terraform Requirements

#### (Optional) Reuse Existing VPC/Subnet

- Create an ECS cluster and configure it with an existing VPC/Subnet configuration suiting your needs.
- Note your [Sysdig SaaS endpoint](https://docs.sysdig.com/en/docs/administration/saas-regions-and-ip-ranges/) and allow both outbound (for compute vulnerability report) and inbound (for scheduled compliance checkups) traffic.
- For an ECS-type deployment, create the [security-group setup](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/modules/services/cloud-connector-ecs/sec-group.tf)

#### (Optional) Sysdig Workload and S3 in Different Accounts

If Sysdig workload (`SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID`) and S3 are set up in different accounts, create a role to allow cross-account access with certain permissions:

1. Create a role, `SysdigSecureForCloud-S3AccessRole`, in the same account where the S3 bucket exists.
2. Give it trust permissions that are necessary.
3. Add the permissions to be able to read from the S3 bucket.

  Create a resource/action pinned policy if required.

  ```text
  {
   "Sid": "AllowSysdigToRead",
   "Effect": "Allow",
   "Action": "s3:GetObject",
   "Resource": [
       "<CLOUDTRAIL_S3_ARN>/*"
   ]
  }
  ```

4. Save the role ARN as `CLOUDTRAIL_S3_ROLE_ARN`.

#### CloudTrail-S3 Ingestion Through Event Forwarding

You can use an S3 Event Forwarder to allow the workload to ingest events if:

- The Cloudtrail-SNS setup is not available
- Cloudtrail-S3 events are located in an account different to the Management account

Secure for Cloud requires an SQS queue from which it can ingest events. You provide the `CLOUDTRAIL_S3_SNS_SQS_ARN` and `CLOUDTRAIL_S3_SNS_SQS_URL` parameters for the installation.

You can use the Sysdig [Cloudtrail S3 bucket event forwarder for an SNS>SQS setup](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/modules/infrastructure/cloudtrail_s3-sns-sqs) to achieve this.

Do not run this module on the same terraform (plan) sequence, because it will have unresolved cycle dependencies and will fail.

```terraform

# provider for S3 account
# this is a sample authentication, can adapt it as long as alias is maintained
provider "aws"{
  alias = "s3"
  region = "<AWS_REGION>"
  assume_role {
    role_arn = "arn:aws:iam::<S3_BUCKET_ACCOUNT_ID>:role/OrganizationAccountAccessRole"
  }
}

module "cloudtrail_s3_sns_sqs" {
  providers = {
    aws = aws.s3
  }
  source  = "sysdiglabs/secure-for-cloud/aws//modules/infrastructure/cloudtrail_s3-sns-sqs"
  cloudtrail_s3_name = "<CLOUDTRAIL_S3_NAME>"
}
```

Inspect `terraform state list` to collect the following:

- `CLOUDTRAIL_S3_SNS_SQS_ARN`
- `CLOUDTRAIL_S3_SNS_SQS_URL`.

#### Launch Terraform Manifest

Create the Terraform manifest using the [organizational example](./examples/organizational/README.md).

##### Parameters

- **General** parameters
  - `AWS_REGION`: Use the same region for both Organizational account and Sysdig workload member account resources.

       Region must be unique for all values and should match the location of the S3 bucket, SNS, and SQS

  - `SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID`: The account where Sysdig workload is to be deployed, optionally, in a pre-existing ECS environment.

- **Cloudtrail S3 SNS-SQS** setup

  - `S3_BUCKET_ACCOUNT_ID`: To authenticate the AWS provider on the member account
  - `CLOUDTRAIL_S3_NAME`: The name of the CloudTrail S3 bucket
  - `CLOUDTRAIL_S3_SNS_SQS_ARN`: The value collected while setting up [CloudTrail-S3 Ingestion Through Event Forwarding](#cloudtrail-s3-ingestion-through-event-forwarding).
  - `CLOUDTRAIL_S3_SNS_SQS_URL` The value collected while setting  up [CloudTrail-S3 Ingestion Through Event Forwarding](#cloudtrail-s3-ingestion-through-event-forwarding).
  - (Optional) `CLOUDTRAIL_S3_ROLE_ARN`: The ARN of the `SysdigSecureForCloud-S3AccessRole` created before for the ECS Task Role to access S3.

- (Optional) Existing **ECS Cluster and networking** setup
  - `ECS_CLUSTER_NAME`: For example, "sfc"
  - `ECS_VPC_ID`:  For example, "vpc-0e91bfef6693f296b"
  - `ECS_VPC_SUBNET_PRIVATE_ID_X`: Two subnets for the VPC. For example, "subnet-0c7d803ecdc88437b"

##### Terraform Manifest

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

# provider used to deploy RO compliance role on organizational accounts
provider "aws" {
  region = "<AWS_REGION>"
}

# provider used to deploy sfc on the selected member-account
# this is a sample authentication, can adapt it as long as alias is maintaned
provider "aws" {
  alias  = "member"
  region = "<AWS_REGION>"
  assume_role {
    # 'OrganizationAccountAccessRole' is the default role created by AWS for management-account users to be able to admin member accounts.
    # if this is changed, please change to the `examples/organizational` input var `organizational_member_default_admin_role` too
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

  #  optional, if no VCP wants to be re-used
  ecs_cluster_name              = "<ECS_CLUSTER_NAME>"
  ecs_vpc_id                    = "<ECS_VPC_ID>"
  ecs_vpc_subnets_private_ids   = ["<ECS_VPC_SUBNET_PRIVATE_ID_1>","<ECS_VPC_SUBNET_PRIVATE_ID_2>"]

  existing_cloudtrail_config={
    cloudtrail_s3_sns_sqs_arn = "<CLOUDTRAIL_S3_SNS_SQS_ARN>"
    cloudtrail_s3_sns_sqs_url = "<CLOUDTRAIL_S3_SNS_SQS_URL>"

    #  optional, only if CLOUDTRAIL_S3 and SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID are in different accounts
    cloudtrail_s3_role_arn    = "<CLOUDTRAIL_S3_ROLE_ARN>"
  }
}
```

#### (Optional) S3 Bucket and Sysdig Workload in Different Accounts

When applying Terraform manifest, if `S3_BUCKET_ACCOUNT_ID` and `SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID` are different, it will create resources but the deployed compute will fail due to permissions. Check the logs in the ECS Task to confirm.

To workaround, you need allow S3 and SQS resources to be accessed by the compute role, `sfc-organizational-ECSTaskRole"`.

![organizational three-way-account permission setup](resources/org-three-with-s3-forward.png)

##### Fetch `SYSDIG_ECS_TASK_ROLE_ARN` ARN

Collect the `SYSDIG_ECS_TASK_ROLE_ARN` ARN to configure your pre-existing `CLOUDTRAIL_S3` and `CLOUDTRAIL_S3_SNS_SQS` permissions to allow Sysdig workload to operate with it.

Set `SYSDIG_ECS_TASK_ROLE_ARN` to `arn:aws:iam::<SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID>:role/sfc-organizational-ECSTaskRole`.

You can check its value by accessing the ECS Cluster and inspecting the deployed Task definition or launching following CLI:

```bash
$ terraform state list | grep aws_iam_role.connector_ecs_task
<RESULTING_RESOURCE>

$ terraform state show <RESULTING_RESOURCE> | grep "arn"
arn = "arn:aws:iam::****:role/sfc-organizational-ECSTaskRole"
```

##### Set Up Cloudtrail-S3-SNS-SQS

Add following permissions to the `CLOUDTRAIL_S3_SNS_SQS`:

```text
    {
      "Sid": "AllowSQSSubscribe",
      "Effect": "Allow",
      "Principal": {
        "AWS": "<SYSDIG_ECS_TASK_ROLE_ARN>"
      },
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage"
      ],
      "Resource": "<CLOUDTRAIL_S3_SNS_SQS_ARN>"
   }
```

##### Set Up Cloudtrail-S3

Add following trust policy to the `CLOUDTRAIL_S3_ROLE`:

```text
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "<SYSDIG_ECS_TASK_ROLE_ARN>"
            },
            "Action": "sts:AssumeRole"
        }
]
}
```

You don't need to restart the ECS Task as this changes will be applied on runtime.

### Verify the Setup

- Access the ECS logs for the Secure for Cloud task and ensure that no errors are reporting and events are being ingested.

- If logs are ok, [confirm that services are working](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/deploy-sysdig-secure-for-cloud-on-aws/#confirm-the-services-are-working).

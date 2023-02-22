# OrganizationSetup - Three way Cross-Account - ECS

## Use-Case explanation

This use case will cover a three-way cross-account setup (typical from AWS ControlTower landing page).
With ECS as workload-type.
<br/>This is terraform-based guidelines, but can also check [Manual Organizational Setup - Three-Way Cross-Account ](./manual-org-three-way.md)


- **User Infrastructure Setup**:

This is the scenario we're going to recreate

  1. Management Account / Accounts
    - Eithere there is an Organizational Cloudtrail reporting to the log archive account
    - Or several accounts reporting to the same log archive account
  2. Log Archive Account
    - Cloudtrail-S3 bucket, with event notification to an SNS > SQS
  3. Workload/Security Member Account
    - Sysdig Secure for cloud deployment
    - Existing VPC network setup.

- Besides, we will make use of an **existing VPC/Subnet configuration**.

- Required **Sysdig Secure For Cloud [Features](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/)**
  - Threat-Detection
  - Posture; Compliance + Identity Access Management
  - :warning: Cloud image scanning is not supported yet
<br/><br/>


## Suggested setup

- Default `organizational` example is pre-configured to work with managed-account level resources (cloudtrail, s3, sns and sqs resources).
  - We will make use of an alternative event ingestion vía S3 Event Notification through an SNS-SQS.
  - It's important that all existing resources (cloudtrail-s3, cloudtrail-s3-sns-sqs, and sysdig workload), are **within same AWS_REGION**. Otherwise, contact us, so we can alleviate this limitation.
  - We will need some permission setup, in order to let Sysdig Modules to be able to read resources from customer's infrastructure setup.
- For existing VPC/Subnet usage, we will make use of the optional variables. Right now these two fields also require an ECS cluster to be configured.


### Step by Step Example Guide

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


#### 1. Configure `AWS_PROFILE` with an organizational Administration credentials

Module is intended to create resources on your management account, as well as member-accounts.

Refer to [General Permissions](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud#required-permissions) to get more detail on what's required,
and [Organizational Role Summary](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/organizational#role-summary) for this specific use-case scenario.

#### 2. Choose an Organizational **Member account for Sysdig Workload** to be deployed.

This accountID will be required in the `SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID` parameter

#### 3. Pre-Terraform Requirements

#### 3.1 ECS Cluster

  - Create an ECS cluster and configure it with the existing VPC/Subnet/... network configuration suiting your needs.
  - Refer to [Sysdig SASS Region and IP Ranges Documentation](https://docs.sysdig.com/en/docs/administration/saas-regions-and-ip-ranges/) to get Sysdig SaaS endpoint and allow both outbound (for compute vulnerability report) and inbound (for scheduled compliance checkups)
  - ECS type deployment will create following [security-group setup](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/modules/services/cloud-connector-ecs/sec-group.tf)

#### 3.2 Permissions - SysdigSecureForCloud-S3AccessRole

Required action to allow AWS S3 cross-account access.

- Create a `SysdigSecureForCloud-S3AccessRole` in the same account where the S3 bucket exists.
- Give it whatever trust-permissions you feel comfortable with, we will edit it later.
- Add permissions to be able to read from the S3 bucket (create a resource/action pinned policy if required)
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
- Fetch the created role arn as `CLOUDTRAIL_S3_ROLE_ARN`

#### 4. Launch Terraform

We will use this Terraform Manifest. Get detailed explanation of each variable bellow.

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

# provider used to deploy RO compliance role on organizational accounts
provider "aws" {
  region = "<AWS_REGION>"       # must match s3 AND sqs region
}

# provider used to deploy sfc on the selected member-account
provider "aws" {
  alias  = "member"
  region = "<AWS_REGION>"       # must match s3 AND sqs region
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

  ecs_cluster_name              = "<ECS_CLUSTER_NAME>"
  ecs_vpc_id                    = "<ECS_VPC_ID>"
  ecs_vpc_subnets_private_ids   = ["<ECS_VPC_SUBNET_PRIVATE_ID_1>","<ECS_VPC_SUBNET_PRIVATE_ID_2>"]

  existing_cloudtrail_config={
      cloudtrail_s3_sns_sqs_arn = "<CLOUDTRAIL_S3_SNS_SQS_ARN>"
      cloudtrail_s3_sns_sqs_url = "<CLOUDTRAIL_S3_SNS_SQS_URL>"
      cloudtrail_s3_role_arn    = "<CLOUDTRAIL_S3_ROLE_ARN>"
  }
}
```

- We'll use the **organizational** example
- **General** parameters
    - `AWS_REGION` Same region is to be used for both organizational managed account and Sysdig workload member account resources.<br/>
        - Region MUST match both S3 bucket, SNS and SQS
    - `SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID` where Sysdig Workload is to be deployed under the pre-existing ECS<br/><br/>

- Existing **ECS Cluster and networking** setup
    - `ECS_CLUSTER_NAME` ex.: "sfc"
    - `ECS_VPC_ID` ex.: "vpc-0e91bfef6693f296b"
    - `ECS_VPC_SUBNET_PRIVATE_ID_X` Two subnets for the VPC. ex.: "subnet-0c7d803ecdc88437b"<br/><br/>

- Existing Organizational **Cloudtrail setup** vía S3 event notification through SNS-SQS.
  - `CLOUDTRAIL_S3_SNS_SQS_ARN` ARN of the queue, for us to setup ECSTaskRole to be able to access SQS
  - `CLOUDTRAIL_S3_SNS_SQS_URL` URL of the queue from were to ingest events in the cloud-connector compute deployment
  - `CLOUDTRAIL_S3_ROLE_ARN` ARN of the `SysdigSecureForCloud-S3AccessRole` created in step 3.2, for ECSTaskRole to assumeRole and access S3

#### 5. Use-Case Specific Permissions

When applying Terraform manifest it will create resources, and we should have no errors there.
However, deployed compute will fail (can check the logs in the ECS Task) due to permissions.

Let's fix that; we need to allow S3 and SQS resources to be accessed by the compute role, `sfc-organizational-ECSTaskRole"` (default name value).

![organizational three-way-account permission setup](resources/org-three-with-s3-forward.png)

##### 5.1 Fetch `SYSDIG_ECS_TASK_ROLE_ARN` ARN

Get this ARN at hand, because it's what you'll use to configure your pre-existing CLOUDTRAIL_S3 and CLOUDTRAIL_S3_SNS_SQS permissions to allow SysdigWorkload to operate with it.

Default `SYSDIG_ECS_TASK_ROLE_ARN` should be `arn:aws:iam::<SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID>:role/sfc-organizational-ECSTaskRole`
but you can check its value accessing the ECS Cluster and checking deployed Task definition, or launching following CLI:
```terraform
$ terraform state list | grep aws_iam_role.connector_ecs_task
<RESULTING_RESOURCE>

$ terraform state show <RESULTING_RESOURCE> | grep "arn"
arn = "arn:aws:iam::****:role/sfc-organizational-ECSTaskRole"
```

##### 5.2 Cloudtrail-S3-SNS-SQS

We'll need to add following permissions to the `CLOUDTRAIL_S3_SNS_SQS`
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

##### 5.3 Cloudtrail-S3

We'll need to add following trust policy to the `CLOUDTRAIL_S3_ROLE`
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

We should not need to restart ECSTask as this changes will be applied on runtime.

### 6. Check-up

Suggested steps

1. Access ECS logs for the SecureForCloud task
    - check that there are no errors and events are being ingested
2. If logs are OK, check in Sysdig Secure
   - Integrations > Data Sources - Cloud Accounts
   - Posture > Identity and Access Management - Overview
   - Posture > Compliance - AWS
   - Insights > Cloud Activity

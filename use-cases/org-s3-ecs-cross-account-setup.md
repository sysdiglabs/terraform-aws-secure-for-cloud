# OrganizationSetup - Existing Cloudtrail with no SNS - S3-SQS event forward cross-account

:warning: WIP.

## Use-Case explanation

**Current User Setup**

- AWS Organization Setup
- AWS Organizational Cloudtrail within the managed account, with no SNS activation
    - we'll leverage Cloudtrail-S3 event forwarder to an SQS
- Cloudtrail-S3 is not in the management account nor in the member account where we will deployed Secure for Cloud.
    - This setup is popular when working under AWS Control Tower setup.
- Existing VPC network setup.

**Sysdig Secure For Cloud [Features](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/)**

- Threat-Detection
- Posture; Compliance + Identity Access Management
  <br/><br/>


## Suggested setup

We're going to use existing use case [/use-cases/org-existing-cloudtrail-ecs-vpc-subnet.md](./org-existing-cloudtrail-ecs-vpc-subnet.md), with some permission-related changes, due to the two-way cross-account scenario.

Final scenario would be:

- Management Account
    - Cloudtrail (no SNS)
- Log-Archive Account
    - Cloudtrail-S3 bucket with SQS event forward? event-bridge?
- Member Account
    - Sysdig Secure for Cloud deployment

It's important that all required resources (cloudtrail-s3, cloudtrail-s3-??, and sysdig workload), is **within same AWS_REGION**. Otherwise, contact us, so we can alleviate this limitation.

For network setup, please refer to [Sysdig SASS Region and IP Ranges Documentation](https://docs.sysdig.com/en/docs/administration/saas-regions-and-ip-ranges/).

Before proceeding, please read the referenced use-cases and examples and check whether you comply with requirements.
Please contact us if something requires to be adjusted.


### Step by Step Example Guide

<!--
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
            "Resource": "arn:aws:s3:::irutest-pre-existing-cloudtrail-s3/*"
        }
    ]
}

0.2. Provision the s3 bucket sqs event-forward into a queue on same region/account
-->


1. Configure `AWS_PROFILE` with an organizational Administration credentials

2. Choose an Organizational **Member account for Sysdig Workload** to be deployed.

    - This accountID will be provided in the `SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID` parameter

3. Use `organizational` example snippet with following parameters

    - General
        - `AWS_REGION` Same region is to be used for both organizational managed account and Sysdig workload member account resources.<br/>
            - **Region MUST match both S3 bucket and SNS Cloudtrail**.
        - `SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID` where Sysdig Workload is to be deployed under the pre-existing ECS

    - Existing Organizational Cloudtrail Setup vía Cloudtrail-S3 SQS event-forwarder
        - `CLOUDTRAIL_S3_SNS_SQS_URL`

    - Existing ECS Cluster Workload  Setup
        - `ECS_CLUSTER_NAME` ex.: "sfc"

    - Existing Networking Setup
        - `ECS_VPC_ID` ex.: "vpc-0e91bfef6693f296b"
        - `ECS_VPC_SUBNET_PRIVATE_ID_X` Two subnets for the VPC. ex.: "subnet-0c7d803ecdc88437b"

4. Permissions - SQS

    - Before running Terraform, we need to give permissions to the role of the `member`-aliased terraform aws provider, to be able to create an SQS queue
      and subscribe it to the provided SNS. Otherwise, Terraform will fail with an error such as
      > AuthorizationError: User: ***  is not authorized to perform: SNS:Subscribe on resource <SNS_ARN>:  because no resource-based policy allows the SNS:Subscribe action
    - We'll need to add following permissions to the SNS queue
   ```text
    {
      "Sid": "AllowSQSSubscribe",
      "Effect": "Allow",
      "Principal": {
        "AWS": "<TERRAFORM_AWS_PROVIDER_MEMBER_ACCOUNT_ROLE_ARN>"
      },
      "Action": "AQS:",
      "Resource": "<CLOUDTRAIL_S3_SNS_SQS_ARN>"
   }
    ```
- Check [`./modules/infrastructure/cloudtrail/sns_permissions.tf`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/modules/infrastructure/cloudtrail/sns_permissions.tf#L22) for more insight


4. Permissions - S3
    - Terraform should have successfully deployed everything, but still, ECS task will fail due to missing permissions on S3 access.
    - We cannot prepare this beforehand, as S3 will throw following error if the referenced Role does not exist yet.
      > Invalid principal in policy
    - For cross-account S3 access, we will provision permissions on both management-account role and s3 bucket
    - For Terraform provisioned role in the management account, `<ARN_SYSDIG_S3_ACCESS_ROLE>`,<br/> in form of `arn:aws:iam::<SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID>:role/sysdig-sfc-SysdigSecureForCloudRole`, <br/>
    ```text
     {
        "Sid": "AllowSysdigReadS3",
        "Effect": "Allow",
        "Action": [
            "s3:GetObject"
        ],
        "Resource": "<ARN_CLOUDTRAIL_S3>/*"
    }
    ```
    - For the S3 bucket
    ```text
    {
        "Sid": "AllowSysdigToRead",
        "Effect": "Allow",
        "Principal": {
            "AWS": "<ARN_SYSDIG_S3_ACCESS_ROLE>" # role created by terraorm , in form of "arn:aws:iam::<SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID>:role/sysdig-sfc-SysdigSecureForCloudRole"
        },
        "Action": "s3:GetObject",
        "Resource": [
            "<CLOUDTRAIL_S3_ARN>",
            "<CLOUDTRAIL_S3_ARN>/*"
        ]
    }
    ```
    - We shouldn't need to restart ECS Task for these roles to be effective and logs should show no errors at this point.

### Permission Setup Guidance

![organizational setup](https://github.com/sysdiglabs/aws-templates-secure-for-cloud/raw/main/use_cases/org-k8s/diagram.png)

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
# this assumeRole / permission setup is referenced in point #3
provider "aws" {
  alias  = "member"
  region = "<AWS_REGION>"       # must match s3 AND sns region
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

  cloudtrail_s3_sns_sqs_url  = "<CLOUDTRAIL_S3_SNS_SQS_ARN>"

  ecs_cluster_name              = "<ECS_CLUSTER_NAME>"
  ecs_vpc_id                    = "<ECS_VPC_ID>"
  ecs_vpc_subnets_private_ids   = ["<ECS_VPC_SUBNET_PRIVATE_ID_1>","<ECS_VPC_SUBNET_PRIVATE_ID_2>"]}
```

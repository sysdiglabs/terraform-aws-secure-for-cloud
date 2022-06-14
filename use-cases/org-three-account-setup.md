# OrganizationSetup - Existing Cloudtrail - Three-way cross-account setup

## Use-Case explanation

**Current User Setup**

- AWS Organization Setup
- AWS Organizational Cloudtrail within the managed account, with Cloudtrail-SNS activation + reporting to another member-account S3 bucket
- Existing VPC network setup.
    
**Sysdig Secure For Cloud [Features](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/)**

- Threat-Detection
- Posture; Compliance + Identity Access Management
  <br/><br/>


## Suggested setup

We're going to use existing use case [/use-cases/org-existing-cloudtrail-ecs-vpc-subnet.md](./org-existing-cloudtrail-ecs-vpc-subnet.md), with some permission-related changes, due to the three-way cross-account scenario.
This setup is popular with user that are under AWS Control Tower Setup

- Management Account 
  - the Cloudtrail-SNS
- Log-Archive Account
  - the Cloudtrail-S3 bucket
- Member Account
  - Sysdig Secure for Cloud deployment

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

0.2. Provision an organizational Cloudtrail/SNS in management account and select the previously created S3
-->


1. Configure `AWS_PROFILE` with an organizational Administration credentials

2. Choose an Organizational **Member account for Sysdig Workload** to be deployed.

    - This accountID will be provided in the `SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID` parameter

3. Permissions - SNS

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
      "Action": "SNS:Subscribe",
      "Resource": "<CLOUDTRAIL_SNS_ARN>"          
   }
    ```
   
4. Use `organizational` example snippet with following parameters

    - General
        - `AWS_REGION` Same region is to be used for both organizational managed account and Sysdig workload member account resources.<br/>
          - **Region MUST match both S3 bucket and SNS Cloudtrail**. 
        - `SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID` where Sysdig Workload is to be deployed under the pre-existing ECS

    - Existing Organizational Cloudtrail Setup
        - `CLOUDTRAIL_SNS_ARN`
        - `CLOUDTRAIL_S3_ARN`
        - You MUST grant manual permissions to the organizational cloudtrail, for the AWS member-account management role `OrganizationAccountAccessRole` to be able to perform `SNS:Subscribe`.
            - This will be required for the CloudConnector SQS Topic subscription.
            - Use [`./modules/infrastructure/cloudtrail/sns_permissions.tf`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/modules/infrastructure/cloudtrail/sns_permissions.tf#L22) as guideline

   - Existing ECS Cluster Workload  Setup
       - `ECS_CLUSTER_NAME` ex.: "sfc"

   - Existing Networking Setup
       - `ECS_VPC_ID` ex.: "vpc-0e91bfef6693f296b"
       - `ECS_VPC_SUBNET_PRIVATE_ID_X` Two subnets for the VPC. ex.: "subnet-0c7d803ecdc88437b"

5. Permissions - S3
    - Terraform should have successfully deployed everything, but still, ECS task will fail due to missing permissions on S3 access.
    - We cannot prepare this beforehand, as S3 will say `Invalid principal in policy` if the referenced Role does not exist yet.
    - For cross-account S3 access, we will provision permissions on both management-account role and s3 bucket
    - For Terraform provisioned role in the management account, "<ARN_SYSDIG_S3_ACCESS_ROLE>", in form of "arn:aws:iam::<SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID>:role/sysdig-sfc-SysdigSecureForCloudRole", <br/>we will add
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

  cloudtrail_sns_arn  = "<CLOUDTRAIL_SNS_ARN>"
  cloudtrail_s3_arn   = "<CLOUDTRAIL_S3_ARN>"
  
  ecs_cluster_name              = "<ECS_CLUSTER_NAME>"
  ecs_vpc_id                    = "<ECS_VPC_ID>"
  ecs_vpc_subnets_private_ids   = ["<ECS_VPC_SUBNET_PRIVATE_ID_1>","<ECS_VPC_SUBNET_PRIVATE_ID_2>"]}
```



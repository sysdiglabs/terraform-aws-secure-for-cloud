# Organization Setup: Single Account Deployment

## Overview

This use case will leverage the [`examples/organizational`](./examples/organizational/README.md) setup within a more limited scope (single-account). Therefore, the CloudTrail you will set up will be organizational.

 > Being able to allow/deny member accounts where Secure for Cloud is deployed is under development.

### Features

This use case provides the following [Sysdig Secure For Cloud](https://docs.sysdig.com/en/docs/sysdig-secure/sysdig-secure-for-cloud/#features) features:

- [Threat Detection](https://docs.sysdig.com/en/docs/sysdig-secure/policies/threat-detect-policies/)

## Preparation

### AWS Terraform Providers

You will work on the following setups: default and member terraform providers.

  1. Member account: Use the [default use-case snippet](#terraform-snippet) to deploy compute and compliance role in a member account.
  2. Management account: Use the [default use-case snippet](#terraform-snippet) to deploy compute  on the Management account.

    ```terraform
    provider "aws" {
      region = var.region
    }


    module "secure_for_cloud_organizational" {
      providers = {
        aws.member = aws
      }
      ...
    }
    ```

## Terraform Snippet

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
    # ORG_MEMBER_SFC_ACCOUNT_ID is the organizational account where sysdig secure for cloud compute component is to be deployed
    # 'OrganizationAccountAccessRole' is the default role created by AWS for management-account users to be able to admin member accounts.
    # if this is changed, please change to the `examples/organizational` input var `organizational_member_default_admin_role` too
    # <br/>https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_access.html
    role_arn = "arn:aws:iam::<SYSDIG_SECURE_FOR_CLOUD_MEMBER_ACCOUNT_ID>:role/OrganizationAccountAccessRole"
  }

module "secure_for_cloud_organizational" {
    providers = {
        aws.member = aws.member
    }
    source = "sysdiglabs/secure-for-cloud/aws//examples/organizational"

    sysdig_secure_for_cloud_member_account_id = "<ORG_MEMBER_SFC_ACCOUNT_ID>"
    ...
}
```

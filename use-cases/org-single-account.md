# OrganizationSetup - Single-Account deployment

## Use-Case explanation

This use case will cover the way of deploying  `examples/organizational` within a more limited scope (single-account)

 > Being able to **allow/deny member accounts** where SecureForCloud is deployed, in organizational example, is under
 > feature-request.

### Scope and Limitations

- While the feature-request is being developed, this workaround will only cover following [features](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud#sysdig-secure-for-cloud-in-aws)
  - [x] Thread Detection
  - [x] Compliance
  - [x] Identity and Access Management
  - [ ] Image scanning
- Because we will still rely on organizational setup, the **cloudtrail will still be organizational**

## Suggested setup

We will rely on

- the `deploy_benchmark_organizational"` input variable of the example.

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deploy_benchmark_organizational"></a> [deploy\_benchmark\_organizational](#input\_deploy\_benchmark\_organizational) | true/false whether benchmark module should be deployed on organizational or single-account mode (1 role per org accounts if true, 1 role in default aws provider account if false)</li></ul> | `bool` | `true` | no |


- the two aws terraform providers (default, member); here we will work two setups
  1. to deploy compute and compliance role **just in one member account**, use [default use-case snippet](#terraform-snippet)
  1. to deploy compute part **on management account**, use following provider setup on the [default use-case snippet](#terraform-snippet)<br/>
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
    deploy_benchmark_organizational = false
    ...
}
```

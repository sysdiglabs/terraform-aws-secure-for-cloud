# Cloud Vision deploy in AWS

This module deploys the CloudVision stack in AWS. It depends on multiple modules that create the infrastructure and
deploy the components of the CloudVision stack.

Each module can be used on its own to deploy the components in existing infrastructure, or can be specified as
parameters.

## Prerequisites

1.  Organization with CloudTrail service enabled
1.  AWS env vars for both `master` and `member` profiles.
    - `master` credentials must be [able to manage cloudtrail creation](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/creating-trail-organization.html)
    > You must be logged in with the management account for the organization to create an organization trail. You must also have sufficient permissions for the IAM user or role in the management account to successfully create an organization trail.


```bash
-- ~/.aws/credentials
[default]
aws_access_key_id=<access key id>
aws_secret_access_key=<aws secret access key>
```

```bash
-- sysdig secure api token env var
export TF_VAR_sysdig_secure_api_token=<api token>


-- organizational sysdig account provisioning parameterization
-- beware, this account's deletion is not approached easily and requires manual attention
-- https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_remove.html#leave-without-all-info

-- create new account (testing purpose)
export TF_VAR_sysdig_account='{create=true, param_creation_email="<an email>"}'
-- use existing account
export TF_VAR_sysdig_account='{create=false, param_use_account_id="<account id>"}'

# optional
# export TF_VAR_sysdig_secure_endpoint=
```


## Usage

@see `/examples` folder

```hcl
module "cloudvision" {

  source  = "sysdiglabs/cloudvision/aws"
  name    = "cloudvision-stack"

  region                            = "eu-central-1"
  sysdig_secure_api_token           = "<API_TOKEN>"
  aws_organizations_account_email   = "<CLOUDVISION_ACCOUNT_EMAIL>"

}
```


## Troubleshooting

- Q: How can I **validate cloudvision provisioning** is working as expected?<br/>
A: Check each pipeline resource is working as expected (from high to low lvl)
  - [ ] are events shown in sysdig secure platform?
  - [ ] are there any errors in the ECS task logs? can also check cloudwatch logs
  - [ ] are events consumed in the sqs queue, or are they pending?
  - [ ] are events being sent to sns topic?


<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_aws.master"></a> [aws.master](#provider\_aws.master) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudtrail_organizational"></a> [cloudtrail\_organizational](#module\_cloudtrail\_organizational) | ./modules/cloudtrail_organizational |  |
| <a name="module_services"></a> [services](#module\_services) | ./modules/services |  |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.cloudvision_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloud_vision_role_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_organizations_account.cloudvision](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account) | resource |
| [aws_iam_policy_document.cloud_vision_role_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloud_vision_role_trusted](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_organizations_account_email"></a> [aws\_organizations\_account\_email](#input\_aws\_organizations\_account\_email) | The email address of the owner to assign to the new member account. This email address must not already be associated with another AWS account | `string` | n/a | yes |
| <a name="input_cloudtrail_organizational_is_multi_region_trail"></a> [cloudtrail\_organizational\_is\_multi\_region\_trail](#input\_cloudtrail\_organizational\_is\_multi\_region\_trail) | true/false whether cloudtrail will ingest multiregional events | `bool` | `true` | no |
| <a name="input_cloudtrail_organizational_s3_kms_enable"></a> [cloudtrail\_organizational\_s3\_kms\_enable](#input\_cloudtrail\_organizational\_s3\_kms\_enable) | true/false whether s3 should be encrypted | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | default region for provisioning | `string` | n/a | yes |
| <a name="input_sysdig_secure_api_token"></a> [sysdig\_secure\_api\_token](#input\_sysdig\_secure\_api\_token) | Sysdig Secure API token | `string` | n/a | yes |
| <a name="input_sysdig_secure_endpoint"></a> [sysdig\_secure\_endpoint](#input\_sysdig\_secure\_endpoint) | Sysdig Secure API endpoint | `string` | `"https://secure.sysdig.com"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | cloudvision tags | `map(string)` | <pre>{<br>  "product": "cloudvision"<br>}</pre> | no |
| <a name="input_terraform_connection_profile"></a> [terraform\_connection\_profile](#input\_terraform\_connection\_profile) | AWS connection profile to be used on ~/.aws/credentials for organization master account | `string` | `"default"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Authors

Module is maintained by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.

# AWS Single-Account User Permissions

Module will create a user with its accessKey/secret, with all the required permissions for `/examples/single-account-k8s` to work.
These permissions are what it's required for both threat-detection and scanning to work.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.50.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.50.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_access_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_user.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy.general](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_iam_policy_document.general](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_secure_api_token_secret_arn"></a> [secure\_api\_token\_secret\_arn](#input\_secure\_api\_token\_secret\_arn) | ARN of Sysdig Secure API token SSM parameter | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances | `string` | `"sfc"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | sysdig secure-for-cloud tags | `map(string)` | <pre>{<br>  "product": "sysdig-secure-for-cloud"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sfc_user_access_key_id"></a> [sfc\_user\_access\_key\_id](#output\_sfc\_user\_access\_key\_id) | Secure for cloud Provisioned user accessKey |
| <a name="output_sfc_user_name"></a> [sfc\_user\_name](#output\_sfc\_user\_name) | Name of the Secure for cloud Provisioned IAM user |
| <a name="output_sfc_user_secret_access_key"></a> [sfc\_user\_secret\_access\_key](#output\_sfc\_user\_secret\_access\_key) | Secure for cloud Provisioned user secretAccessKey |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.

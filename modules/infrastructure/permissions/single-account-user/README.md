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
| [aws_iam_user_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssm_parameter.sysdig_secure_api_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudtrail_s3_bucket_arn"></a> [cloudtrail\_s3\_bucket\_arn](#input\_cloudtrail\_s3\_bucket\_arn) | ARN of cloudtrail s3 bucket | `string` | n/a | yes |
| <a name="input_cloudtrail_sns_subscribed_sqs_arns"></a> [cloudtrail\_sns\_subscribed\_sqs\_arns](#input\_cloudtrail\_sns\_subscribed\_sqs\_arns) | List of ARNs of the cloudtrail-sns subscribed sqs's | `list(string)` | n/a | yes |
| <a name="input_scanning_build_project_arn"></a> [scanning\_build\_project\_arn](#input\_scanning\_build\_project\_arn) | ARN of codebuild to launch the image scanning process | `string` | n/a | yes |
| <a name="input_secure_api_token_secret_name"></a> [secure\_api\_token\_secret\_name](#input\_secure\_api\_token\_secret\_name) | Sysdig Secure API token SSM parameter name | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances | `string` | `"sfc"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | sysdig secure-for-cloud tags | `map(string)` | <pre>{<br>  "product": "sysdig-secure-for-cloud"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s4c_user_access_key_id"></a> [s4c\_user\_access\_key\_id](#output\_s4c\_user\_access\_key\_id) | Secure-for-cloud Provisioned user accessKey |
| <a name="output_s4c_user_secret_access_key"></a> [s4c\_user\_secret\_access\_key](#output\_s4c\_user\_secret\_access\_key) | Secure-for-cloud Provisioned user secretAccessKey |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.

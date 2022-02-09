# Permissions :: Single-Account user credentials

Creates an IAM user and adds permissions for required modules.
<br/>Will use the `deploy_threat_detection` and `deploy_image_scanning` flags

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_credentials_cloud_connector"></a> [credentials\_cloud\_connector](#module\_credentials\_cloud\_connector) | ../cloud-connector | n/a |
| <a name="module_credentials_cloud_scanning"></a> [credentials\_cloud\_scanning](#module\_credentials\_cloud\_scanning) | ../cloud-scanning | n/a |
| <a name="module_credentials_general"></a> [credentials\_general](#module\_credentials\_general) | ../general | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_access_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_user.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudtrail_s3_bucket_arn"></a> [cloudtrail\_s3\_bucket\_arn](#input\_cloudtrail\_s3\_bucket\_arn) | ARN of cloudtrail s3 bucket | `string` | `"*"` | no |
| <a name="input_cloudtrail_subscribed_sqs_arn"></a> [cloudtrail\_subscribed\_sqs\_arn](#input\_cloudtrail\_subscribed\_sqs\_arn) | ARN of the cloudtrail subscribed sqs's | `string` | `"*"` | no |
| <a name="input_deploy_image_scanning"></a> [deploy\_image\_scanning](#input\_deploy\_image\_scanning) | true/false whether to provision cloud\_scanning permissions | `bool` | `true` | no |
| <a name="input_deploy_threat_detection"></a> [deploy\_threat\_detection](#input\_deploy\_threat\_detection) | true/false whether to provision cloud\_connector permissions | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances | `string` | `"sfc"` | no |
| <a name="input_scanning_codebuild_project_arn"></a> [scanning\_codebuild\_project\_arn](#input\_scanning\_codebuild\_project\_arn) | ARN of codebuild to launch the image scanning process | `string` | `"*"` | no |
| <a name="input_ssm_secure_api_token_arn"></a> [ssm\_secure\_api\_token\_arn](#input\_ssm\_secure\_api\_token\_arn) | ARN of the security credentials for the secure\_api\_token | `string` | `"*"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sfc_user_access_key_id"></a> [sfc\_user\_access\_key\_id](#output\_sfc\_user\_access\_key\_id) | Secure for cloud Provisioned user accessKey |
| <a name="output_sfc_user_arn"></a> [sfc\_user\_arn](#output\_sfc\_user\_arn) | ARN of the Secure for cloud Provisioned IAM user |
| <a name="output_sfc_user_name"></a> [sfc\_user\_name](#output\_sfc\_user\_name) | Name of the Secure for cloud Provisioned IAM user |
| <a name="output_sfc_user_secret_access_key"></a> [sfc\_user\_secret\_access\_key](#output\_sfc\_user\_secret\_access\_key) | Secure for cloud Provisioned user secretAccessKey |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.

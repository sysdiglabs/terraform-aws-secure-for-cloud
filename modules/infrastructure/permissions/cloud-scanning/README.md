# Permissions :: Cloud Scanning

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.50.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.12.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_user_policy.cloud_scanner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_iam_policy_document.cloud_scanner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_user.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_user) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudtrail_subscribed_sqs_arn"></a> [cloudtrail\_subscribed\_sqs\_arn](#input\_cloudtrail\_subscribed\_sqs\_arn) | ARN of the cloudtrail subscribed sqs's | `string` | n/a | yes |
| <a name="input_scanning_codebuild_project_arn"></a> [scanning\_codebuild\_project\_arn](#input\_scanning\_codebuild\_project\_arn) | ARN of codebuild to launch the image scanning process | `string` | n/a | yes |
| <a name="input_sfc_user_name"></a> [sfc\_user\_name](#input\_sfc\_user\_name) | Name of the IAM user to provision permissions | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances | `string` | `"sfc"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.

# AWS Organizational Cloudvision Role


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
| <a name="provider_aws.member"></a> [aws.member](#provider\_aws.member) | >= 3.50.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.cloudvision_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudvision_role_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.enable_assume_cloudvision_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_policy_document.cloudvision_role_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudvision_role_trusted](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.enable_assume_cloudvision_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_role.ecs_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudconnector_ecs_task_role_name"></a> [cloudconnector\_ecs\_task\_role\_name](#input\_cloudconnector\_ecs\_task\_role\_name) | cloudconnector ecs task role name | `string` | n/a | yes |
| <a name="input_cloudtrail_s3_arn"></a> [cloudtrail\_s3\_arn](#input\_cloudtrail\_s3\_arn) | Cloudtrail S3 bucket ARN | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name for the Cloud Connector deployment | `string` | `"cloud-connector"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | sysdig cloudvision tags | `map(string)` | <pre>{<br>  "product": "sysdig-cloudvision"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudvision_role_arn"></a> [cloudvision\_role\_arn](#output\_cloudvision\_role\_arn) | organizational cloudvision role arn |
| <a name="output_cloudvision_role_name"></a> [cloudvision\_role\_name](#output\_cloudvision\_role\_name) | organizational cloudvision role name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.

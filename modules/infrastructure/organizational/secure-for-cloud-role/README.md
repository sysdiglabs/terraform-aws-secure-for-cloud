# AWS Organizational Secure for Cloud Role


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
| [aws_iam_role.secure_for_cloud_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.enable_assume_secure_for_cloud_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.sysdig_secure_for_cloud_role_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_policy_document.enable_assume_secure_for_cloud_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sysdig_secure_for_cloud_role_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sysdig_secure_for_cloud_role_trusted](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_role.ecs_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudconnector_ecs_task_role_name"></a> [cloudconnector\_ecs\_task\_role\_name](#input\_cloudconnector\_ecs\_task\_role\_name) | cloudconnector ecs task role name | `string` | n/a | yes |
| <a name="input_cloudtrail_s3_arn"></a> [cloudtrail\_s3\_arn](#input\_cloudtrail\_s3\_arn) | Cloudtrail S3 bucket ARN | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name for the Cloud Connector deployment | `string` | `"sysdig-secure-for-cloud"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | sysdig secure-for-cloud tags | `map(string)` | <pre>{<br>  "product": "sysdig-secure-for-cloud"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sysdig_secure_for_cloud_role_arn"></a> [sysdig\_secure\_for\_cloud\_role\_arn](#output\_sysdig\_secure\_for\_cloud\_role\_arn) | organizational secure-for-cloud role arn |
| <a name="output_sysdig_secure_for_cloud_role_name"></a> [sysdig\_secure\_for\_cloud\_role\_name](#output\_sysdig\_secure\_for\_cloud\_role\_name) | organizational secure-for-cloud role name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.

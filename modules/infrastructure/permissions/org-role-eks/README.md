# AWS Organizational Secure for Cloud Role for EKS

The aim of this module is to manage the organizational **managed account** required role and permissions for threat-detection and image scanning modules to work properly.

1. Enables Cloudtrail SNS subscription permissions through a role specified within the Sysdig Secure workload **member account**
2. Creates a role in the organizational **managed account** with the required permissions

* Threat-Detection
  * S3 Get and List permissions in order to fetch the events
  * SNS Subscription permissions in order to subscribe a topic to it

* Image scanning
  * Enable this role to assumeRole to member accounts through the `organizational_role_per_account` role,
    in order to be able to fetch images that may be in member-account repositories

* Other permissions
  * ECS-Task roles (of both modules) to be able to assume this role


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.50.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.21.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.secure_for_cloud_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.sysdig_secure_for_cloud_role_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.sysdig_secure_for_cloud_role_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_policy_document.sysdig_secure_for_cloud_role_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sysdig_secure_for_cloud_role_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sysdig_secure_for_cloud_role_trusted](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudtrail_s3_arn"></a> [cloudtrail\_s3\_arn](#input\_cloudtrail\_s3\_arn) | Cloudtrail S3 bucket ARN | `string` | n/a | yes |
| <a name="input_user_arn"></a> [user\_arn](#input\_user\_arn) | ARN of the IAM user to which roles will be added | `string` | n/a | yes |
| <a name="input_deploy_image_scanning"></a> [deploy\_image\_scanning](#input\_deploy\_image\_scanning) | true/false whether to provision cloud\_scanning permissions | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances | `string` | `"sfc"` | no |
| <a name="input_organizational_role_per_account"></a> [organizational\_role\_per\_account](#input\_organizational\_role\_per\_account) | Name of the organizational role deployed by AWS in each account of the organization | `string` | `"OrganizationAccountAccessRole"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | sysdig secure-for-cloud tags. always include 'product' default tag for resource-group proper functioning | `map(string)` | <pre>{<br>  "product": "sysdig-secure-for-cloud"<br>}</pre> | no |

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

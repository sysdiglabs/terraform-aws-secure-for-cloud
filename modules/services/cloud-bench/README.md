# Cloud Bench deploy in AWS Module


Deployed on the **target AWS account(s)**:

- The required IAM Role and IAM Policies (`arn:aws:iam::aws:policy/SecurityAudit`)  to allow Sysdig to run AWS Benchmarks on your behalf.
  - A Sysdig provided `ExternalId` will be used.
  - This is done using `aws_cloudformation_stack_set`.

Deployed on **Sysdig Backend**
- The required provisioning on Sysdig Backend to use the `ExternalId`-basedIAM Role with an AssumeRole.
- An `aws_foundations_bench-1.3.0` benchmak task schedule on a random hour of the day `rand rand * * *`


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.62.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig) | >= 0.5.21 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.62.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |
| <a name="provider_sysdig"></a> [sysdig](#provider\_sysdig) | >= 0.5.21 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudformation_stack_set.stackset](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_set) | resource |
| [aws_cloudformation_stack_set_instance.stackset_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_set_instance) | resource |
| [aws_iam_role.cloudbench_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cloudbench_security_audit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [random_integer.hour](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [random_integer.minute](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [sysdig_secure_benchmark_task.benchmark_task](https://registry.terraform.io/providers/sysdiglabs/sysdig/latest/docs/resources/secure_benchmark_task) | resource |
| [sysdig_secure_cloud_account.cloud_account](https://registry.terraform.io/providers/sysdiglabs/sysdig/latest/docs/resources/secure_cloud_account) | resource |
| [aws_caller_identity.me](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy.security_audit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.trust_relationship](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_organizations_organization.org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [sysdig_secure_trusted_cloud_identity.trusted_identity](https://registry.terraform.io/providers/sysdiglabs/sysdig/latest/docs/data-sources/secure_trusted_cloud_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_benchmark_regions"></a> [benchmark\_regions](#input\_benchmark\_regions) | List of regions in which to run the benchmark. If empty, the task will contain all aws regions by default. | `list(string)` | `[]` | no |
| <a name="input_is_organizational"></a> [is\_organizational](#input\_is\_organizational) | whether secure-for-cloud should be deployed in an organizational setup | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the IAM Role that will be created. | `string` | `"sfc-cloudbench"` | no |
| <a name="input_provision_in_management_account"></a> [provision\_in\_management\_account](#input\_provision\_in\_management\_account) | Whether to deploy the stack in the management account | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | Default region for resource creation in organization mode | `string` | `"eu-central-1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | sysdig secure-for-cloud tags | `map(string)` | <pre>{<br>  "product": "sysdig-secure-for-cloud"<br>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.

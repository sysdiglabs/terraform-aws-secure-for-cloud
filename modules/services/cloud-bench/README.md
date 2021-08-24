# Cloud Bench deploy in AWS Module

Deploys

- the required IAM Role and IAM Policies to allow Sysdig to run AWS Benchmarks on your behalf
- An `aws_foundations_bench-1.3.0` benchmak task schedule on  `0 6 * * *`



<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.50.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig) | >= 0.5.18 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.50.0 |
| <a name="provider_sysdig"></a> [sysdig](#provider\_sysdig) | >= 0.5.18 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.cloudbench_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cloudbench_security_audit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [sysdig_secure_benchmark_task.benchmark_task](https://registry.terraform.io/providers/sysdiglabs/sysdig/latest/docs/resources/secure_benchmark_task) | resource |
| [sysdig_secure_cloud_account.cloud_account](https://registry.terraform.io/providers/sysdiglabs/sysdig/latest/docs/resources/secure_cloud_account) | resource |
| [aws_iam_policy.security_audit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.trust_relationship](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_regions.regions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/regions) | data source |
| [sysdig_secure_trusted_cloud_identity.trusted_identity](https://registry.terraform.io/providers/sysdiglabs/sysdig/latest/docs/data-sources/secure_trusted_cloud_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | the account\_id in which to provision the cloud-bench IAM role | `string` | n/a | yes |
| <a name="input_regions"></a> [regions](#input\_regions) | List of regions in which to run the benchmark. If empty, the task will contain all aws regions by default. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | sysdig secure-for-cloud tags | `map(string)` | <pre>{<br>  "product": "sysdig-secure-for-cloud"<br>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.

# Sysdig Secure for Cloud in AWS :: Single-Account

Deploy Sysdig Secure for Cloud in a single AWS account. All the required resources and workloads will be run
under the same AWS account.

![organizational diagram](https://raw.githubusercontent.com/sysdiglabs/terraform-aws-cloudvision/master/examples/single-account/diagram-single.png)

## Prerequisites

Minimum requirements:

1. AWS profile credentials configuration of the desired credentials
1. Secure requirements, as input variable value
    ```
    sysdig_secure_api_token=<SECURE_API_TOKEN>
    ```

## Usage

For quick testing, use this snippet on your terraform files

```terraform
module "cloudvision_aws_single_account" {
  source = "sysdiglabs/cloudvision/aws//examples/single-account"

  sysdig_secure_api_token        = "00000000-1111-2222-3333-444444444444"
}
```

See main module [`variables.tf`](https://github.com/sysdiglabs/terraform-aws-cloudvision/blob/master/examples/single-account/variables.tf) or [inputs summary](#inputs) file for more optional configuration.

To run this example you need have your [aws master-account profile configured in CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) and to execute:
```terraform
$ terraform init
$ terraform plan
$ terraform apply
```

Note that:
  - This example will create resources that cost money. Run `terraform destroy` when you don't need them anymore
  - For more detailed configuration inspect both main module and example input variables
  - All created resources will be created within the tags `product:sysdig-cloudvision`, within the resource-group `sysdig-cloudvision`

---


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.50.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig) | >= 0.5.17 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_connector"></a> [cloud\_connector](#module\_cloud\_connector) | ../../modules/services/cloud-connector |  |
| <a name="module_cloud_scanning"></a> [cloud\_scanning](#module\_cloud\_scanning) | ../../modules/services/cloud-scanning |  |
| <a name="module_cloudtrail"></a> [cloudtrail](#module\_cloudtrail) | ../../modules/infrastructure/cloudtrail |  |
| <a name="module_codebuild"></a> [codebuild](#module\_codebuild) | ../../modules/infrastructure/codebuild |  |
| <a name="module_ecs_fargate_cluster"></a> [ecs\_fargate\_cluster](#module\_ecs\_fargate\_cluster) | ../../modules/infrastructure/ecs-fargate-cluster |  |
| <a name="module_resource_group_master"></a> [resource\_group\_master](#module\_resource\_group\_master) | ../../modules/infrastructure/resource-group |  |
| <a name="module_ssm"></a> [ssm](#module\_ssm) | ../../modules/infrastructure/ssm |  |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sysdig_secure_api_token"></a> [sysdig\_secure\_api\_token](#input\_sysdig\_secure\_api\_token) | Sysdig Secure API token | `string` | n/a | yes |
| <a name="input_cloudtrail_is_multi_region_trail"></a> [cloudtrail\_is\_multi\_region\_trail](#input\_cloudtrail\_is\_multi\_region\_trail) | testing/economization purpose. true/false whether cloudtrail will ingest multiregional events | `bool` | `true` | no |
| <a name="input_cloudtrail_kms_enable"></a> [cloudtrail\_kms\_enable](#input\_cloudtrail\_kms\_enable) | testing/economization purpose. true/false whether s3 should be encrypted | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the Cloud Vision deployment | `string` | `"sysdig-cloudvision"` | no |
| <a name="input_region"></a> [region](#input\_region) | Default region for resource creation in both organization master and cloudvision member account | `string` | `"eu-central-1"` | no |
| <a name="input_sysdig_secure_endpoint"></a> [sysdig\_secure\_endpoint](#input\_sysdig\_secure\_endpoint) | Sysdig Secure API endpoint | `string` | `"https://secure.sysdig.com"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | sysdig cloudvision tags | `map(string)` | <pre>{<br>  "product": "sysdig-cloudvision"<br>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

---

## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.

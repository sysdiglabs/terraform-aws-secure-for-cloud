# Example: Single-Account Cloudvision

- A single AWS account usage approach, where resources will report to the account `Cloudtrail`service
- In this account,
    - All the cloudvision service-related resources will be created
    - Cloudwatch `cloud-connect` logs and event-alerts files will be generated

![organizational diagram](./diagram-single.png)

## Prerequisites

Minimum requirements:

1.  AWS profile credentials configuration of the desired account
1. Secure requirements, as input variable value
    ```
    sysdig_secure_api_token=<SECURE_API_TOKEN>
    ```

See main module [variables.tf](./variables.tf) file for more optional configuration.



## Usage

For quick testing, use this snippet on your terraform files

```terraform
module "aws_cloudvision_organizational" {
  source = "sysdiglabs/cloudvision/aws//examples/single-account"

  sysdig_secure_api_token        = "00000000-1111-2222-3333-444444444444"
}
```

To run this example you need have your [aws master-account `default` profile configured in CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) and to execute:
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

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudvision"></a> [cloudvision](#module\_cloudvision) | ../../ |  |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sysdig_secure_api_token"></a> [sysdig\_secure\_api\_token](#input\_sysdig\_secure\_api\_token) | Sysdig Secure API token | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name to be assigned to all child resources | `string` | `"sysdig-cloudvision"` | no |
| <a name="input_region"></a> [region](#input\_region) | Default region for resource creation in the account | `string` | `"eu-central-1"` | no |
| <a name="input_sysdig_secure_endpoint"></a> [sysdig\_secure\_endpoint](#input\_sysdig\_secure\_endpoint) | Sysdig Secure API endpoint | `string` | `"https://secure.sysdig.com"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

---

## Authors

Module is maintained by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.

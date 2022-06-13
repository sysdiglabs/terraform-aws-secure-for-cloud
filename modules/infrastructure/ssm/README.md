# AWS System Manager


Sysdig Secure for Cloud uses [ssm](https://docs.aws.amazon.com/systems-manager/latest/userguide/what-is-systems-manager.html) in order to store the `sysdig_secure_api_token` parameter in its "Parameter Store"
and pass it, in a safe way, to all the modules that require it.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.50.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.18.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.secure_api_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sysdig_secure_api_token"></a> [sysdig\_secure\_api\_token](#input\_sysdig\_secure\_api\_token) | Sysdig Secure API token | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances | `string` | `"sfc"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | sysdig secure-for-cloud tags. always include 'product' default tag for resource-group proper functioning | `map(string)` | <pre>{<br>  "product": "sysdig-secure-for-cloud"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secure_api_token_secret_arn"></a> [secure\_api\_token\_secret\_arn](#output\_secure\_api\_token\_secret\_arn) | ARN of Sysdig Secure API Token secret |
| <a name="output_secure_api_token_secret_name"></a> [secure\_api\_token\_secret\_name](#output\_secure\_api\_token\_secret\_name) | Name of Sysdig Secure API Token secret |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.

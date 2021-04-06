# Cloud Scanning CodeBuild deploy in AWS Module

![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/sysdiglabs/terraform-aws-cloud-scanning)

## Usage

```hcl
module "scanning_codebuild" {
  source = "sysdiglabs/cloudvision/aws/modules/scanning-codebuild"
  name   = "scanning-codebuild"

  ssm_endpoint = "ssm_secret_secure_endpoint"
  ssm_token    = "ssm_secret_secure_api_token"
}
```

## Requirements

No requirements.

## Providers

| Name                                              | Version     |
| ------------------------------------------------- | ----------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | > = v3.34.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                           | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_cloudwatch_log_group.log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)               | resource    |
| [aws_codebuild_project.build_project](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project)           | resource    |
| [aws_iam_role.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                   | resource    |
| [aws_iam_role_policy.logs_publisher](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)              | resource    |
| [aws_iam_role_policy.parameter_reader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)            | resource    |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)      | data source |
| [aws_iam_policy_document.logs_publisher](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)   | data source |
| [aws_iam_policy_document.parameter_reader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_ssm_parameter.api_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter)                    | data source |
| [aws_ssm_parameter.endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter)                     | data source |

## Inputs

| Name                                                                        | Description                                                            | Type     | Default                      | Required |
| --------------------------------------------------------------------------- | ---------------------------------------------------------------------- | -------- | ---------------------------- |:--------:|
| <a name="input_log_retention"></a> [log\_retention](#input\_log\_retention) | Days to keep logs from builds                                          | `number` | `30`                         |    no    |
| <a name="input_name"></a> [name](#input\_name)                              | Name for the Cloud Scanning CodeBuild deployment                       | `string` | `"cloud-scanning-codebuild"` |    no    |
| <a name="input_ssm_endpoint"></a> [ssm\_endpoint](#input\_ssm\_endpoint)    | Name of the parameter in SSM containing the Sysdig Secure Endpoint URL | `string` | n/a                          |   yes    |
| <a name="input_ssm_token"></a> [ssm\_token](#input\_ssm\_token)             | Name of the parameter in SSM containing the Sysdig Secure API Token    | `string` | n/a                          |   yes    |
| <a name="input_verify_ssl"></a> [verify\_ssl](#input\_verify\_ssl)          | Whether to verify the SSL certificate of the endpoint or not           | `bool`   | `true`                       |    no    |

## Outputs

| Name                                                                 | Description                 |
| -------------------------------------------------------------------- | --------------------------- |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | ID of the CodeBuild project |

## Authors

Module is maintained by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
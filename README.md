# Cloud Vision deploy in AWS

This module deploys the CloudVision stack in AWS. It depends on multiple modules that create the infrastructure and
deploy the components of the CloudVision stack.

Each module can be used on its own to deploy the components in existing infrastructure, or can be specified as
parameters.

## Usage

```hcl
module "cloudvision" {
  source = "sysdiglabs/cloudvision/aws"
  name   = "cloudvision-stack"
  
  sysdig_secure_api_token = "<API_TOKEN>"
}
```

## Requirements

No requirements.

## Providers

| Name                                              | Version     |
| ------------------------------------------------- | ----------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | > = v3.34.0 |

## Modules

| Name                                                                                              | Source                                                    | Version |
| ------------------------------------------------------------------------------------------------- | --------------------------------------------------------- | ------- |
| <a name="module_cloud_bench"></a> [cloud\_bench](#module\_cloud\_bench)                           | sysdiglabs/cloudvision/aws/modules/aws-cloudbench         |         |
| <a name="module_cloud_connector"></a> [cloud\_connector](#module\_cloud\_connector)               | sysdiglabs/cloudvision/aws/modules/aws-cloudconnector     |         |
| <a name="module_cloud_scanning"></a> [cloud\_scanning](#module\_cloud\_scanning)                  | sysdiglabs/cloudvision/aws/modules/aws-cloudscanning      |         |
| <a name="module_cloudtrail"></a> [cloudtrail](#module\_cloudtrail)                                | sysdiglabs/cloudvision/aws/modules/aws-cloudtrail         |         |
| <a name="module_ecs_fargate_cluster"></a> [ecs\_fargate\_cluster](#module\_ecs\_fargate\_cluster) | sysdiglabs/cloudvision/aws/modules/aws-ecscluster         |         |
| <a name="module_scanning_codebuild"></a> [scanning\_codebuild](#module\_scanning\_codebuild)      | sysdiglabs/cloudvision/aws/modules/aws-scanning-codebuild |         |

## Resources

| Name                                                                                                                            | Type     |
| ------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_s3_bucket.s3_config_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)         | resource |
| [aws_ssm_parameter.secure_api_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.secure_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter)  | resource |

## Inputs

| Name                                                                                                                                                   | Description                                  | Type           | Default                       | Required |
| ------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------- | -------------- | ----------------------------- |:--------:|
| <a name="input_deploy_cloudbench"></a> [deploy\_cloudbench](#input\_deploy\_cloudbench)                                                                | Deploy the CloudBench module                 | `bool`         | `true`                        |    no    |
| <a name="input_deploy_cloudconnector"></a> [deploy\_cloudconnector](#input\_deploy\_cloudconnector)                                                    | Deploy the CloudConnector module             | `bool`         | `true`                        |    no    |
| <a name="input_deploy_ecr_scanning"></a> [deploy\_ecr\_scanning](#input\_deploy\_ecr\_scanning)                                                        | Deploy the ECR Scanning module               | `bool`         | `true`                        |    no    |
| <a name="input_deploy_ecs_scanning"></a> [deploy\_ecs\_scanning](#input\_deploy\_ecs\_scanning)                                                        | Deploy the ECS Scanning module               | `bool`         | `true`                        |    no    |
| <a name="input_existing_cloud_trail_sns_topic"></a> [existing\_cloud\_trail\_sns\_topic](#input\_existing\_cloud\_trail\_sns\_topic)                   | Use an existing CloudTrail SNS Topic         | `string`       | `""`                          |    no    |
| <a name="input_existing_ecs_cluster"></a> [existing\_ecs\_cluster](#input\_existing\_ecs\_cluster)                                                     | Use an existing ECS cluster                  | `string`       | `""`                          |    no    |
| <a name="input_existing_ecs_cluster_private_subnets"></a> [existing\_ecs\_cluster\_private\_subnets](#input\_existing\_ecs\_cluster\_private\_subnets) | Use the existing ECS cluster private subnets | `list(string)` | `[]`                          |    no    |
| <a name="input_existing_ecs_cluster_vpc"></a> [existing\_ecs\_cluster\_vpc](#input\_existing\_ecs\_cluster\_vpc)                                       | Use an existing ECS cluster VPC              | `string`       | `""`                          |    no    |
| <a name="input_name"></a> [name](#input\_name)                                                                                                         | Name for the Cloud Vision deployment         | `string`       | n/a                           |   yes    |
| <a name="input_sysdig_secure_api_token"></a> [sysdig\_secure\_api\_token](#input\_sysdig\_secure\_api\_token)                                          | Sysdig Secure API token                      | `string`       | n/a                           |   yes    |
| <a name="input_sysdig_secure_endpoint"></a> [sysdig\_secure\_endpoint](#input\_sysdig\_secure\_endpoint)                                               | Sysdig Secure API endpoint                   | `string`       | `"https://secure.sysdig.com"` |    no    |

## Outputs

No outputs.

## Authors

Module is maintained by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
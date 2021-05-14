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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.35.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudtrail"></a> [cloudtrail](#module\_cloudtrail) | ./modules/cloudtrail |  |
| <a name="module_cloudvision_components"></a> [cloudvision\_components](#module\_cloudvision\_components) | ./modules/cloudvision-mainaccount |  |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudbench_deploy"></a> [cloudbench\_deploy](#input\_cloudbench\_deploy) | Deploy the CloudBench module | `bool` | `true` | no |
| <a name="input_cloudconnector_deploy"></a> [cloudconnector\_deploy](#input\_cloudconnector\_deploy) | Deploy the CloudConnector module | `bool` | `true` | no |
| <a name="input_ecr_image_scanning_deploy"></a> [ecr\_image\_scanning\_deploy](#input\_ecr\_image\_scanning\_deploy) | Deploy the ECR Scanning module | `bool` | `true` | no |
| <a name="input_ecs_image_scanning_deploy"></a> [ecs\_image\_scanning\_deploy](#input\_ecs\_image\_scanning\_deploy) | Deploy the ECS Scanning module | `bool` | `true` | no |
| <a name="input_existing_cloudtrail_sns_topic"></a> [existing\_cloudtrail\_sns\_topic](#input\_existing\_cloudtrail\_sns\_topic) | Use an existing CloudTrail SNS Topic | `string` | `""` | no |
| <a name="input_existing_ecs_cluster"></a> [existing\_ecs\_cluster](#input\_existing\_ecs\_cluster) | Use an existing ECS cluster | `string` | `""` | no |
| <a name="input_existing_ecs_cluster_private_subnets"></a> [existing\_ecs\_cluster\_private\_subnets](#input\_existing\_ecs\_cluster\_private\_subnets) | Use the existing ECS cluster private subnets | `list(string)` | `[]` | no |
| <a name="input_existing_ecs_cluster_vpc"></a> [existing\_ecs\_cluster\_vpc](#input\_existing\_ecs\_cluster\_vpc) | Use an existing ECS cluster VPC | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the Cloud Vision deployment | `string` | n/a | yes |
| <a name="input_sysdig_secure_api_token"></a> [sysdig\_secure\_api\_token](#input\_sysdig\_secure\_api\_token) | Sysdig Secure API token | `string` | n/a | yes |
| <a name="input_sysdig_secure_endpoint"></a> [sysdig\_secure\_endpoint](#input\_sysdig\_secure\_endpoint) | Sysdig Secure API endpoint | `string` | `"https://secure.sysdig.com"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
# AWS ECS Cluster deployment module

This repository contains a Module for how to deploy a Fargate ECS Cluster.

## Usage

```hcl
module "ecs_fargate_cluster" {
  source = "sysdiglabs/cloudvision/aws/modules/ecscluster"

  name = "ecscluster"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws |  |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.ecs_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_availability_zones.zones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Deployment name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | ECS Cluster ID |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | VPC Private Subnets |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | VPC Public Subnets |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
<!-- END_TF_DOCS -->

## Authors

Module is maintained by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
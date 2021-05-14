# AWS ECS Cluster deployment module

This repository contains a Module for how to deploy a Fargate ECS Cluster.

## Usage

```hcl
module "ecs_fargate_cluster" {
  source = "sysdiglabs/cloudvision/aws/modules/ecscluster"

  name = "ecscluster"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.35.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.35.0 |

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
| <a name="input_naming_prefix"></a> [naming\_prefix](#input\_naming\_prefix) | Prefix for resource names. Use the default unless you need to install multiple instances, and modify the deployment at the main account accordingly | `string` | `"SysdigCloud"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | ECS Cluster ID |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | VPC Private Subnets |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | VPC Public Subnets |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
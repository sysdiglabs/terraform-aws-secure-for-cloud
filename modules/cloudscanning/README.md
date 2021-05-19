# Cloud Scanning deploy in AWS Module

![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/sysdiglabs/terraform-aws-cloud-scanning)

This repository contains a Module for how to deploy the Cloud Scanning in AWS as an ECS container deployment that will
detect events in your infrastructure.

## Usage

```hcl
module "ecs_fargate_cluster" {
  source = "sysdiglabs/cloudvision/aws/modules/ecscluster"

  name = "ecscluster"
}

module "cloudtrail" {
  source = "sysdiglabs/cloudvision/aws/modules/cloudtrail"
  name   = "cloud-trail-cloud-connector"

  bucket_name            = "cloud-trail-bucket"
}

module "scanning_codebuild" {
  source = "sysdiglabs/cloudvision/aws/modules/scanning-codebuild"
  name   = "scanning-codebuild"

  ssm_endpoint = "ssm_secret_secure_endpoint"
  ssm_token    = "ssm_secret_secure_api_token"
}

module "cloudscanning" {
  source = "sysdiglabs/cloudvision/aws/modules/cloudscanning"

  codebuild_project = module.scanning_codebuild.project_id
  deploy_ecr        = true
  deploy_ecs        = true
  ecs_cluster       = module.ecs_fargate_cluster.id
  vpc               = module.ecs_fargate_cluster.vpc_id
  subnets           = module.ecs_fargate_cluster.private_subnets

  sns_topic_arn = module.cloudtrail.topic_arn

  ssm_endpoint = "ssm_secret_secure_endpoint"
  ssm_token    = "ssm_secret_secure_api_token"
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
| <a name="module_scanning_codebuild"></a> [scanning\_codebuild](#module\_scanning\_codebuild) | ../cloudscanning-codebuild |  |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.task_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_security_group.sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecs_cluster.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudtrail_ingestor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.code_build_scan_executor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecr_reader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.execution_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.execution_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.secrets_reader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_definition_reader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_read_parameters](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssm_parameter.api_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accounts_and_regions"></a> [accounts\_and\_regions](#input\_accounts\_and\_regions) | A list of child AWS accounts and regions where CloudTrail is enabled. | <pre>list(object({<br>    account_id = string<br>    region     = string<br>  }))</pre> | `[]` | no |
| <a name="input_deploy_ecr"></a> [deploy\_ecr](#input\_deploy\_ecr) | Enable ECR integration | `bool` | n/a | yes |
| <a name="input_deploy_ecs"></a> [deploy\_ecs](#input\_deploy\_ecs) | Enable ECS integration | `bool` | n/a | yes |
| <a name="input_ecs_cluster"></a> [ecs\_cluster](#input\_ecs\_cluster) | ECS Fargate Cluster where deploy the CloudConnector workload | `string` | n/a | yes |
| <a name="input_extra_env_vars"></a> [extra\_env\_vars](#input\_extra\_env\_vars) | Extra environment variables for the Cloud Scanning deployment | `map(string)` | `{}` | no |
| <a name="input_image"></a> [image](#input\_image) | Image of the cloud scanning to deploy | `string` | `"sysdiglabs/cloud-scanning:latest"` | no |
| <a name="input_log_retention"></a> [log\_retention](#input\_log\_retention) | Days to keep logs for CloudConnector | `number` | `5` | no |
| <a name="input_naming_prefix"></a> [naming\_prefix](#input\_naming\_prefix) | Prefix for resource names. Use the default unless you need to install multiple instances, and modify the deployment at the main account accordingly | `string` | `"SysdigCloud"` | no |
| <a name="input_ssm_endpoint"></a> [ssm\_endpoint](#input\_ssm\_endpoint) | Name of the parameter in SSM containing the Sysdig Secure Endpoint URL | `string` | n/a | yes |
| <a name="input_ssm_token"></a> [ssm\_token](#input\_ssm\_token) | Name of the parameter in SSM containing the Sysdig Secure API Token | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Subnets where the CloudConnector will be deployed | `list(string)` | n/a | yes |
| <a name="input_verify_ssl"></a> [verify\_ssl](#input\_verify\_ssl) | Whether to verify the SSL certificate of the endpoint or not | `bool` | `true` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | VPC where the workload is deployed | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
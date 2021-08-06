# Cloud Connector deploy in AWS Module

[Cloud Connector](https://github.com/sysdiglabs/cloud-connector)

Deploys a Cloud Connector in AWS as an ECS container deployment that will detect events in your infrastructure.

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

module "cloud_connector_aws" {
  source = "sysdiglabs/cloudvision/aws/modules/cloudconnector"

  name     = "cloud-connector"
  config_bucket = "cloud-connector-config-s3-bucket"
  ecs_cluster   = "existing_ecs_cluster"

  sns_topic_arn = "arn:topic"

  ssm_endpoint = "sysdig_secure_url_secret"
  ssm_token    = "sysdig_secure_api_token_secret"

  subnets = ["0.0.0.0/0"]
  vpc     = "existing_vpc_id"


  config_content = <<EOF
logging: info
rules:
  - secure:
      url: "" // Will be retrieved from the ssm_endpoint
  - s3:
      bucket: config_bucket_name
      path: rules
ingestors:
  - cloudtrail-sns-sqs:
      queueURL: "https://aws.sqs.queue.url/" // Fill your own SQS Queue URL
      interval: 25s
notifiers:
  - cloudwatch:
      logGroup: "aws_cloudwatch_log_group_name"
      logStream: "aws_cloudwatch_log_stream_name"
  - securityhub:
      productArn: arn:aws:securityhub:<REGION>::product/sysdig/sysdig-cloud-connector
  - secure:
      url: "" // Will be retrieved from the ssm_endpoint
EOF
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.50.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.50.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_ecs_service.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.task_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.task_read_parameters](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_s3_bucket.s3_config_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_object.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object) | resource |
| [aws_s3_bucket_public_access_block.s3_config_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_security_group.sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_sns_topic_subscription.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sqs_queue.sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.cloudtrail_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_ssm_parameter.secure_api_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.secure_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_caller_identity.me](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecs_cluster.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster) | data source |
| [aws_iam_policy_document.cloudtrail_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.execution_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.iam_role_task_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_read_parameters](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ecs_cluster"></a> [ecs\_cluster](#input\_ecs\_cluster) | ECS Fargate Cluster where deploy the CloudConnector workload | `string` | n/a | yes |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | CloudTrail module created SNS Topic ARN | `string` | n/a | yes |
| <a name="input_sysdig_secure_api_token"></a> [sysdig\_secure\_api\_token](#input\_sysdig\_secure\_api\_token) | Sysdig Secure API token | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC where the workload is deployed | `string` | n/a | yes |
| <a name="input_vpc_subnets"></a> [vpc\_subnets](#input\_vpc\_subnets) | Subnets where the CloudConnector will be deployed | `list(string)` | n/a | yes |
| <a name="input_cloudwatch_log_retention"></a> [cloudwatch\_log\_retention](#input\_cloudwatch\_log\_retention) | Days to keep logs for CloudConnector | `number` | `5` | no |
| <a name="input_extra_env_vars"></a> [extra\_env\_vars](#input\_extra\_env\_vars) | Extra environment variables for the Cloud Connector deployment | `map(string)` | `{}` | no |
| <a name="input_image"></a> [image](#input\_image) | Image of the cloud connector to deploy | `string` | `"sysdiglabs/cloud-connector:latest"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the Cloud Connector deployment | `string` | `"cloud-connector"` | no |
| <a name="input_organizational_setup"></a> [organizational\_setup](#input\_organizational\_setup) | whether organizational setup is to be enabled. if true, services\_assume\_role\_arn, for cloud\_connect to assumeRole and read events on master account | <pre>object({<br>    is_organizational        = bool<br>    services_assume_role_arn = string<br>  })</pre> | <pre>{<br>  "is_organizational": false,<br>  "services_assume_role_arn": null<br>}</pre> | no |
| <a name="input_sysdig_secure_endpoint"></a> [sysdig\_secure\_endpoint](#input\_sysdig\_secure\_endpoint) | Sysdig Secure API endpoint | `string` | `"https://secure.sysdig.com"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | sysdig cloudvision tags | `map(string)` | <pre>{<br>  "product": "sysdig-cloudvision"<br>}</pre> | no |
| <a name="input_verify_ssl"></a> [verify\_ssl](#input\_verify\_ssl) | true/false to determine ssl verification | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_task_role_arn"></a> [ecs\_task\_role\_arn](#output\_ecs\_task\_role\_arn) | cloudconnect ecs task role arn |
| <a name="output_ecs_task_role_name"></a> [ecs\_task\_role\_name](#output\_ecs\_task\_role\_name) | cloudconnect ecs task role name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.

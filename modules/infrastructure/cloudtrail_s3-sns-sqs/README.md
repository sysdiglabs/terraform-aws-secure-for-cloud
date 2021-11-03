# Cloudtrail_S3 event notification handle through SNS-SQS

Provisions the SNS-SQS event-notification on a pre-existing cloudtrail, based on it S3 bucket event-notifications

## Pre-requirements
- SNS must be created in the same region as Cloudtrail. Adjust `var.region` or your aws credentials region.



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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudtrail_s3_sns_sqs"></a> [cloudtrail\_s3\_sns\_sqs](#module\_cloudtrail\_s3\_sns\_sqs) | ../sqs-sns-subscription |  |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | ../resource-group |  |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket_notification.bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_sns_topic.s3_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_s3_bucket.cloudtrail_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudtrail_s3_name"></a> [cloudtrail\_s3\_name](#input\_cloudtrail\_s3\_name) | Name of the Cloudtrail S3 bucket | `string` | n/a | yes |
| <a name="input_event_notification_filter_prefix"></a> [event\_notification\_filter\_prefix](#input\_event\_notification\_filter\_prefix) | n/a | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances | `string` | `"sfc"` | no |
| <a name="input_region"></a> [region](#input\_region) | Default region for resource creation in both organization master and secure-for-cloud member account | `string` | `"eu-central-1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | sysdig secure-for-cloud tags | `map(string)` | <pre>{<br>  "product": "sysdig-secure-for-cloud"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudtrail_s3_arn"></a> [cloudtrail\_s3\_arn](#output\_cloudtrail\_s3\_arn) | ARN of the SQS topic subscribed to the SNS of Cloudtrail-S3 bucket |
| <a name="output_cloudtrail_subscribed_sqs_arn"></a> [cloudtrail\_subscribed\_sqs\_arn](#output\_cloudtrail\_subscribed\_sqs\_arn) | ARN of the SQS topic subscribed to the SNS of Cloudtrail-S3 bucket |
| <a name="output_cloudtrail_subscribed_sqs_url"></a> [cloudtrail\_subscribed\_sqs\_url](#output\_cloudtrail\_subscribed\_sqs\_url) | URL of the SQS topic subscribed to the SNS of Cloudtrail-S3 bucket |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.

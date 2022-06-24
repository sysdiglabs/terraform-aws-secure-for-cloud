# Cloudtrail S3 event notification handle through SNS-SQS

In order cloud-connector module to be able to ingest cloudtrail events through the cloudtrail-s3 ingestor, provided by the [S3 event notification system](https://docs.aws.amazon.com/AmazonS3/latest/userguide/notification-how-to-event-types-and-destinations.html#amazon-sns-topic) (insted of cloudtdrail-sns ones), it needs an sqs queue URL from where to get the events.

This way of ingesting, is the [`aws-cloudtrail-s3-sns-sqs` ingestor](https://charts.sysdig.com/charts/cloud-connector/#ingestors)
It requires:
 - `queueURL`: the url of the sqs queue
 - `assumeRole`: optional; the role need to be able to fetch the events to the S3 bucket (as the event payload is not coming in the sqs message)

This module helps with the creation of the SQS queue from which to pull the cloudtrail events, leveraging the S3 "bucket event notification" system.

Module gets the cloudtrail-s3 bucket name as input and provides the sqs topic url as output.

# How it works

- This module's output will be visible in the `S3` console, after entering a bucket, in it's `Properties`, `Event notifications` section.
Besides, an SQS queue will be visible, which will gather the events coming from the Cloudtrail-S3-SNS topic notifications.
- Creates the SNS-SQS link using the underlying module `modules/infrastructure/sqs-sns-subscription`<br/><br/>

## Recommended use-cases

Matches one of the following points:

- Accounts are organized in an AWS Organization, but there is NO [Organizational Cloudtrail](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/creating-trail-organization.html)
- An existing cloudtrail is available, but it has NO
[Cloudtrail-SNS notification configured](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/configure-sns-notifications-for-cloudtrail.html?icmpid=docs_console_unmapped)
- An existing cloudtrail is available, but despite having Cloudtrail-SNS notification activated we want to make an
EVENT FILTER/fine-tunning, regarding what we want to send to Sysdig Cloud-Connector for the thread-detection feature.

## Pre-requirements
- Identify the Cloudtrail-S3 bucket name, for the `input_cloudtrail_s3_name` module input
<!--
- SNS must be created in the same region as Cloudtrail. Adjust `var.region` or your aws credentials region.
-->


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.50.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.19.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudtrail_s3_sns_sqs"></a> [cloudtrail\_s3\_sns\_sqs](#module\_cloudtrail\_s3\_sns\_sqs) | ../sqs-sns-subscription | n/a |

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
| <a name="input_name"></a> [name](#input\_name) | Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances | `string` | `"sfc"` | no |
| <a name="input_s3_event_notification_filter_prefix"></a> [s3\_event\_notification\_filter\_prefix](#input\_s3\_event\_notification\_filter\_prefix) | S3 Path filter prefix for event notification. Limit the notifications to objects with key starting with specified characters | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | sysdig secure-for-cloud tags. always include 'product' default tag for resource-group proper functioning | `map(string)` | <pre>{<br>  "product": "sysdig-secure-for-cloud"<br>}</pre> | no |

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

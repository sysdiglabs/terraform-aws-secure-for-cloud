# AWS CloudTrail deployment module

This repository contains a Module for how to deploy an AWS CloudTrail.

## Usage

```hcl
module "cloudtrail" {
  source = "sysdiglabs/cloudvision/aws/modules/cloudtrail"
  name   = "cloud-trail"

  bucket_name            = "cloud-trail-bucket-cloud-connector"
  bucket_expiration_days = 5
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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudtrail.trail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_kms_alias.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_sns_topic.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.sqs_cloudconnector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sns_topic_subscription.sqs_cloudscanning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sqs_queue.sqs_cloudconnector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.sqs_cloudscanning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.sqs_cloudconnector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_sqs_queue_policy.sqs_cloudscanning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_caller_identity.me](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sns_topic_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sqs_cloudconnector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sqs_cloudscanning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudtrail_log_retention"></a> [cloudtrail\_log\_retention](#input\_cloudtrail\_log\_retention) | Days to keep logs from CloudTrail in S3 bucket. | `number` | `5` | no |
| <a name="input_existing_cloudtrail_sns_topic"></a> [existing\_cloudtrail\_sns\_topic](#input\_existing\_cloudtrail\_sns\_topic) | Provide an existing CloudTrail SNS Topic, or leave it blank to let us to deploy the infrastructure required for running Sysdig for Cloud. | `string` | `""` | no |
| <a name="input_multi_region_trail"></a> [multi\_region\_trail](#input\_multi\_region\_trail) | Specify if the cloud trail to create needs to be multi regional | `bool` | `true` | no |
| <a name="input_naming_prefix"></a> [naming\_prefix](#input\_naming\_prefix) | Prefix for resource names. Use the default unless you need to install multiple instances, and modify the deployment at the main account accordingly | `string` | `"SysdigCloud"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | SNS Topic where CloudTrail events are published |
| <a name="output_sqs_cloudconnector"></a> [sqs\_cloudconnector](#output\_sqs\_cloudconnector) | SQS Queue for CloudConnector notifications |
| <a name="output_sqs_cloudscanning"></a> [sqs\_cloudscanning](#output\_sqs\_cloudscanning) | SQS Queue for CloudScanning notifications |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
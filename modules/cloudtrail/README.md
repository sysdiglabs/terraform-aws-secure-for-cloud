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

## Requirements

No requirements.

## Providers

| Name                                              | Version     |
| ------------------------------------------------- | ----------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | > = v3.34.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                             | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| [aws_cloudtrail.trail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail)                                   | resource    |
| [aws_kms_alias.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias)                                | resource    |
| [aws_kms_key.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)                                    | resource    |
| [aws_s3_bucket.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                | resource    |
| [aws_s3_bucket_policy.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)                  | resource    |
| [aws_sns_topic.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic)                                       | resource    |
| [aws_sns_topic_policy.cloudtrail-watched](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy)          | resource    |
| [aws_sns_topic_policy.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy)                         | resource    |
| [aws_caller_identity.me](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                         | data source |
| [aws_iam_policy_document.cloudtrail-watched](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)     | data source |
| [aws_iam_policy_document.s3_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)   | data source |
| [aws_iam_policy_document.sns_topic_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)   | data source |

## Inputs

| Name                                                                                                     | Description                                                                                    | Type     | Default | Required |
| -------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- | -------- | ------- |:--------:|
| <a name="input_bucket_expiration_days"></a> [bucket\_expiration\_days](#input\_bucket\_expiration\_days) | Number of days that the logs will persist in the bucket                                        | `number` | `5`     |    no    |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name)                                    | Bucket name that will be created with the cloud trail resources, where the logs will be saved. | `string` | n/a     |   yes    |
| <a name="input_main_account_id"></a> [main\_account\_id](#input\_main\_account\_id)                      | ID of the main account that can be subscribed to the SNS created                               | `string` | n/a     |   yes    |
| <a name="input_name"></a> [name](#input\_name)                                                           | Deployment name                                                                                | `string` | n/a     |   yes    |

## Outputs

| Name                                                              | Description          |
| ----------------------------------------------------------------- | -------------------- |
| <a name="output_topic_arn"></a> [topic\_arn](#output\_topic\_arn) | ARN of the SNS topic |

## Authors

Module is maintained by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
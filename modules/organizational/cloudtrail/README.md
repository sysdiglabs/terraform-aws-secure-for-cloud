# AWS Organizational CloudTrail deployment module

## Usage

```hcl
module "cloudtrail" {
  source = "sysdiglabs/cloudvision/aws/modules/organizational/cloudtrail"

  cloudtrail_name   = "cloudtrail-org-tf"
  s3_bucket_name    = "cloudtrail-org-tf"
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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudtrail.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_kms_alias.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_resourcegroups_group.cloudvision](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/resourcegroups_group) | resource |
| [aws_s3_bucket.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_sns_topic.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_caller_identity.me](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cloudtrail_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudtrail_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudtrail_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudtrail_name"></a> [cloudtrail\_name](#input\_cloudtrail\_name) | CloudTrail name | `string` | n/a | yes |
| <a name="input_cloudvision_product_tags"></a> [cloudvision\_product\_tags](#input\_cloudvision\_product\_tags) | n/a | `map(string)` | <pre>{<br>  "product": "cloudvision"<br>}</pre> | no |
| <a name="input_s3_bucket_expiration_days"></a> [s3\_bucket\_expiration\_days](#input\_s3\_bucket\_expiration\_days) | Number of days that the logs will persist in the bucket | `number` | `5` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | S3 bucket name that will be created with the CloudTrail resources, where the logs will be saved. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | ARN of the SNS topic |
<!-- END_TF_DOCS -->

## Authors

Module is maintained by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
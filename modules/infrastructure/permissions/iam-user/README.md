# Permissions :: Single-Account user credentials

Creates an IAM user and adds permissions for required modules.
<br/>Will use the `deploy_image_scanning` flag to pin down specific feature-permissions.


## Access Key Rotation
This module creates a user, and its `aws_iam_access_key` in order Kubernetes-based examples to be able to work with its
core component [`cloud-connector` helm chart](https://charts.sysdig.com/charts/cloud-connector/)

As AWS Best practices suggest, this **key SHOULD be rotated before 90 days**,  but it's not in Sysdig Terraform module's
responsibility to do so.

Here some guidelines though:

- Up till day, nor AWS nor Terraform do offer an official automatic key rotation.
- There are several workarounds [[1]](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_RotateAccessKey) [[2]](https://aws-rotate-iam-keys.com/) [[3]](https://github.com/GSA/aws-access-key-rotation-lambda), but all require some way of detecting the closeness of this date, and a workload to force the key generation.
- What we suggest, is to
  1. Create a detection system to know when the access key is nearing the 90 day mark (ex.: cloudwatch daily checkup, cron task , ...)
  2. Optionally, [Terraform Refresh](https://learn.hashicorp.com/tutorials/terraform/refresh) your terraform state beforehand, to avoid confussion with 3rd step
    ```shell
      $ terraform apply -refresh-only
    ```
  3. [Terraform Taint/Replace](https://www.terraform.io/cli/commands/taint) the `aws_iam_access_key` so that a new key is created and propagated to the [`cloud-connector` helm chart](https://charts.sysdig.com/charts/cloud-connector/).
     <br/>This will ask a confirmation, after showing the plan, where the access_key will be replaced and the helm chart updated
    ```shell
      $ terraform state list | grep aws_iam_access_key
      module.cloudvision_aws_single_account_k8s.module.iam_user.aws_iam_access_key.this

      $ terraform apply -replace="module.cloudvision_aws_single_account_k8s.module.iam_user.aws_iam_access_key.this"
    ```

Note: Contact us if this authentication system does not match your requirement.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.50.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_credentials_cloud_connector"></a> [credentials\_cloud\_connector](#module\_credentials\_cloud\_connector) | ../cloud-connector | n/a |
| <a name="module_credentials_cloud_scanning"></a> [credentials\_cloud\_scanning](#module\_credentials\_cloud\_scanning) | ../cloud-scanning | n/a |
| <a name="module_credentials_general"></a> [credentials\_general](#module\_credentials\_general) | ../general | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_access_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_user.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudtrail_s3_bucket_arn"></a> [cloudtrail\_s3\_bucket\_arn](#input\_cloudtrail\_s3\_bucket\_arn) | ARN of cloudtrail s3 bucket | `string` | `"*"` | no |
| <a name="input_cloudtrail_subscribed_sqs_arn"></a> [cloudtrail\_subscribed\_sqs\_arn](#input\_cloudtrail\_subscribed\_sqs\_arn) | ARN of the cloudtrail subscribed sqs's | `string` | `"*"` | no |
| <a name="input_deploy_image_scanning"></a> [deploy\_image\_scanning](#input\_deploy\_image\_scanning) | true/false whether to provision cloud\_scanning permissions | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances | `string` | `"sfc"` | no |
| <a name="input_scanning_codebuild_project_arn"></a> [scanning\_codebuild\_project\_arn](#input\_scanning\_codebuild\_project\_arn) | ARN of codebuild to launch the image scanning process | `string` | `"*"` | no |
| <a name="input_ssm_secure_api_token_arn"></a> [ssm\_secure\_api\_token\_arn](#input\_ssm\_secure\_api\_token\_arn) | ARN of the security credentials for the secure\_api\_token | `string` | `"*"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sfc_user_access_key_id"></a> [sfc\_user\_access\_key\_id](#output\_sfc\_user\_access\_key\_id) | Secure for cloud Provisioned user accessKey |
| <a name="output_sfc_user_arn"></a> [sfc\_user\_arn](#output\_sfc\_user\_arn) | ARN of the Secure for cloud Provisioned IAM user |
| <a name="output_sfc_user_name"></a> [sfc\_user\_name](#output\_sfc\_user\_name) | Name of the Secure for cloud Provisioned IAM user |
| <a name="output_sfc_user_secret_access_key"></a> [sfc\_user\_secret\_access\_key](#output\_sfc\_user\_secret\_access\_key) | Secure for cloud Provisioned user secretAccessKey |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.

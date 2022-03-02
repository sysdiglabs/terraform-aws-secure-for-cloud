# Sysdig Secure for Cloud in AWS<br/>:: Organizational, threat-detection with pre-existing resources (EKS + cloudtrail through S3-SNS-SQS events)


- Sysdig **Helm** chart will be used to deploy threat-detection
    - [Cloud-Connector Chart](https://charts.sysdig.com/charts/cloud-connector/)
    - This charts requires specific AWS credentials to be passed by parameter (accessKeyId and secretAccessKey)
- An existing cloudtrail is used, but instead of sending events directly to an SNS topic (disabled), we will make use of a topic (SQS)
  which will be subscribed to the multiple possible SNS topics listening to the cloudtrail-S3 bucket changes.

![diagram](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/examples-internal/organizational-k8s-threat-reuse_cloudtrail_s3/diagram.png)

All the required resources and workloads will be run under the same AWS account, held in a member-account of the organization.

## Prerequisites

Minimum requirements:

1. Configure [Terraform **AWS** Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
2. Configure [**Helm** Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs) for **Kubernetes** cluster
3. **Sysdig** Secure API token , as input variable value
    ```
    sysdig_secure_api_token=<SECURE_API_TOKEN>
    ```
4. **SQS topic** subscribed to the Cloudtrail-S3-SNS event notifications.<br/>
This three-actor setup (S3-SNS-SQS) can be manually provisioned, or handled through `modules/infrastructure/cloudtrail_s3-sns-sqs` module<br/><br/>
Client is responsible for provisioning the ARN of this SQS, which will be required as an input parameter.<br/>


## Notice

* **Resource creation inventory** Find all the resources created by Sysdig examples in the resource-group `sysdig-secure-for-cloud` (AWS Resource Group & Tag Editor) <br/><br/>
* **Deployment cost** This example will create resources that cost money.<br/>Run `terraform destroy` when you don't need them anymore


## Usage

For quick testing, use this snippet on your terraform files.

```terraform
terraform {
  required_providers {
    sysdig = {
      source  = "sysdiglabs/sysdig"
      configuration_aliases = [aws.member]
    }
  }
}

provider "sysdig" {
  sysdig_secure_api_token    = "00000000-1111-2222-3333-444444444444"
}

provider "aws" {
  region = "<AWS-REGION>; ex. us-east-1"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "org_k8s_threat_reuse_cloudtrail" {
  source = "sysdiglabs/secure-for-cloud/aws//examples-internal/organizational-k8s-threat-reuse_cloudtrail"

  region                          = "CLOUDTRAIL_SNS_SQS_REGION"
  cloudtrail_s3_sns_sqs_url       = "SQS-URL"

  aws_access_key_id         = "AWS_ACCESSK_KEY"
  aws_secret_access_key     = "AWS_SECRET_ACCESS_KEY"
}

```

See [inputs summary](#inputs) or module module [`variables.tf`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/examples-internal/organizational-k8s-threat-reuse_cloudtrail/variables.tf) file for more optional configuration.

To run this example you need have your [aws account profile configured in CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) and to execute:
```terraform
$ terraform init
$ terraform plan
$ terraform apply
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.50.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >=2.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.1.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.4.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | ../../modules/infrastructure/resource-group | n/a |
| <a name="module_ssm"></a> [ssm](#module\_ssm) | ../../modules/infrastructure/ssm | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.cloud_connector](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_access_key_id"></a> [aws\_access\_key\_id](#input\_aws\_access\_key\_id) | cloud-connector. aws credentials in order to access required aws resources. aws.accessKeyId | `string` | n/a | yes |
| <a name="input_aws_secret_access_key"></a> [aws\_secret\_access\_key](#input\_aws\_secret\_access\_key) | cloud-connector. aws credentials in order to access required aws resources. aws.secretAccessKey | `string` | n/a | yes |
| <a name="input_cloudtrail_s3_sns_sqs_url"></a> [cloudtrail\_s3\_sns\_sqs\_url](#input\_cloudtrail\_s3\_sns\_sqs\_url) | Organization cloudtrail event notification  S3-SNS-SQS URL to listen to | `string` | n/a | yes |
| <a name="input_sysdig_secure_api_token"></a> [sysdig\_secure\_api\_token](#input\_sysdig\_secure\_api\_token) | Sysdig Secure API token | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances | `string` | `"sfc"` | no |
| <a name="input_sysdig_secure_url"></a> [sysdig\_secure\_endpoint](#input\_sysdig\_secure\_endpoint) | Sysdig Secure API endpoint | `string` | `"https://secure.sysdig.com"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | sysdig secure-for-cloud tags | `map(string)` | <pre>{<br>  "product": "sysdig-secure-for-cloud"<br>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->


## Troubleshooting

- Q1: When I deploy it, cloud-connector gives an error saying `api error AWS.SimpleQueueService.NonExistentQueue: The specified queue does not exist for this wsdl version`
  S1: make use of the `var.region` to specify where the resources are on the organzation managed account (sqs)

## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.

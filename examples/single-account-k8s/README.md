# Sysdig Secure for Cloud in AWS <br/>[ Example :: Single-Account on Kubernetes Cluster ]

Deploy Sysdig Secure for Cloud in a provided existing Kubernetes Cluster.

- Sysdig **Helm** [cloud-connector chart](https://charts.sysdig.com/charts/cloud-connector/) will be used to deploy threat-detection and scanning features
  <br/>Because these charts require specific AWS credentials to be passed by parameter, a new user + access key will be created within account. See [`credentials.tf`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/examples/single-account-k8s/credentials.tf)
- Used architecture is similar to [single-account](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/examples/single-account) but changing ECS <---> with an existing K8s cluster (EKS or vanilla)

### Notice
* All the required resources and workloads will be run under the **same AWS account**. <br/><br/>
* All Sysdig Secure for Cloud features **but [Image Scanning](https://docs.sysdig.com/en/docs/sysdig-secure/scanning/)** are enabled by default. You can enable it through `deploy_image_scanning_ecr` and `deploy_image_scanning_ecs` input variable parameters.<br/><br/>
* **Resource creation inventory** Find all the resources created by Sysdig examples in the resource-group `sysdig-secure-for-cloud` (AWS Resource Group & Tag Editor) <br/><br/>
* **Deployment cost** This example will create resources that cost money.<br/>Run `terraform destroy` when you don't need them anymore


<img src="https://raw.githubusercontent.com/sysdiglabs/terraform-aws-secure-for-cloud/master/examples/single-account-k8s/diagram.png" alt="single-account-k8s diagram" style="zoom: 50%;" />

## Prerequisites

Minimum requirements:

1. Configure [Terraform **AWS** Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
2. Configure [**Helm** Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs) for **Kubernetes** cluster
3. **Sysdig** Secure requirements, as input variable value
   ```
   sysdig_secure_api_token=<SECURE_API_TOKEN>
   ```

## Usage

For quick testing, use this snippet on your terraform files

```terraform
terraform {
  required_providers {
    sysdig = {
      source  = "sysdiglabs/sysdig"
    }
  }
}

provider "sysdig" {
  sysdig_secure_url         = "<SYSDIG_SECURE_URL>"
  sysdig_secure_api_token   = "<SYSDIG_SECURE_API_TOKEN>"
}

provider "aws" {
  region = "<AWS-REGION>; ex. us-east-1"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "secure_for_cloud_aws_single_account_k8s" {
  source = "sysdiglabs/secure-for-cloud/aws//examples/single-account-k8s"
}
```

See [inputs summary](#inputs) or module module [`variables.tf`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/examples/single-account-k8s/variables.tf) file for more optional configuration.

To run this example you need have your [aws account profile configured in CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) and to execute:

```terraform
$ terraform init
$ terraform plan
$ terraform apply
```


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >=2.3.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig) | >= 0.5.33 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.23.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.6.0 |
| <a name="provider_sysdig"></a> [sysdig](#provider\_sysdig) | 0.5.39 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_bench"></a> [cloud\_bench](#module\_cloud\_bench) | ../../modules/services/cloud-bench | n/a |
| <a name="module_cloud_connector_sqs"></a> [cloud\_connector\_sqs](#module\_cloud\_connector\_sqs) | ../../modules/infrastructure/sqs-sns-subscription | n/a |
| <a name="module_cloudtrail"></a> [cloudtrail](#module\_cloudtrail) | ../../modules/infrastructure/cloudtrail | n/a |
| <a name="module_codebuild"></a> [codebuild](#module\_codebuild) | ../../modules/infrastructure/codebuild | n/a |
| <a name="module_iam_user"></a> [iam\_user](#module\_iam\_user) | ../../modules/infrastructure/permissions/iam-user | n/a |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | ../../modules/infrastructure/resource-group | n/a |
| <a name="module_ssm"></a> [ssm](#module\_ssm) | ../../modules/infrastructure/ssm | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.cloud_connector](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [sysdig_secure_connection.current](https://registry.terraform.io/providers/sysdiglabs/sysdig/latest/docs/data-sources/secure_connection) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_benchmark_regions"></a> [benchmark\_regions](#input\_benchmark\_regions) | List of regions in which to run the benchmark. If empty, the task will contain all aws regions by default. | `list(string)` | `[]` | no |
| <a name="input_cloudtrail_is_multi_region_trail"></a> [cloudtrail\_is\_multi\_region\_trail](#input\_cloudtrail\_is\_multi\_region\_trail) | true/false whether cloudtrail will ingest multiregional events. testing/economization purpose. | `bool` | `true` | no |
| <a name="input_cloudtrail_kms_enable"></a> [cloudtrail\_kms\_enable](#input\_cloudtrail\_kms\_enable) | true/false whether s3 should be encrypted. testing/economization purpose. | `bool` | `true` | no |
| <a name="input_cloudtrail_sns_arn"></a> [cloudtrail\_sns\_arn](#input\_cloudtrail\_sns\_arn) | ARN of a pre-existing cloudtrail\_sns. If defaulted, a new cloudtrail will be created. If specified, deployment region must match Cloudtrail S3 bucket region | `string` | `"create"` | no |
| <a name="input_deploy_benchmark"></a> [deploy\_benchmark](#input\_deploy\_benchmark) | Whether to deploy or not the cloud benchmarking | `bool` | `true` | no |
| <a name="input_deploy_image_scanning_ecr"></a> [deploy\_image\_scanning\_ecr](#input\_deploy\_image\_scanning\_ecr) | true/false whether to deploy the image scanning on ECR pushed images | `bool` | `false` | no |
| <a name="input_deploy_image_scanning_ecs"></a> [deploy\_image\_scanning\_ecs](#input\_deploy\_image\_scanning\_ecs) | true/false whether to deploy the image scanning on ECS running images | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances | `string` | `"sfc"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | sysdig secure-for-cloud tags. always include 'product' default tag for resource-group proper functioning | `map(string)` | <pre>{<br>  "product": "sysdig-secure-for-cloud"<br>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.

# Sysdig Secure for Cloud in AWS :: Single-Account on Kubernetes Cluster

Deploy Sysdig Secure for Cloud in a provided existing Kubernetes Cluster.

- Sysdig **Helm** charts will be used to deploy threat-detection and scanning modules
  - [Cloud-Connector Chart](https://charts.sysdig.com/charts/cloud-connector/)
  - [Cloud-Scanning Chart](https://charts.sysdig.com/charts/cloud-scanning/)
  - Because these charts require specific AWS credentials to be passed by parameter, a new user + access key will be created within account. See [`credentials.tf`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/examples/single-account-k8s/credentials.tf)
- Used arquitecture is similar to [single-account](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/examples/single-account) but changing ECS <---> with an existing EKS

All the required resources and workloads will be run under the same AWS account.

## Prerequisites

Minimum requirements:

1. AWS profile credentials configuration
2. A Kubernetes cluster configured within your `~/.kube/config`
3. Secure requirements, as input variable value
    ```
    sysdig_secure_api_token=<SECURE_API_TOKEN>
    ```

## Usage

For quick testing, use this snippet on your terraform files

```terraform
module "secure_for_cloud_aws_single_account" {
  source = "sysdiglabs/secure-for-cloud/aws//examples/single-account-k8s"

  sysdig_secure_api_token        = "00000000-1111-2222-3333-444444444444"
}
```

See [inputs summary](#inputs) or module module [`variables.tf`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/examples/single-account-k8s/variables.tf) file for more optional configuration.

To run this example you need have your [aws account profile configured in CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) and to execute:
```terraform
$ terraform init
$ terraform plan
$ terraform apply
```

Notice that:
* This example will create resources that cost money.<br/>Run `terraform destroy` when you don't need them anymore
* All created resources will be created within the tags `product:sysdig-secure-for-cloud`, within the resource-group `sysdig-secure-for-cloud`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.50.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >=2.3.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig) | >= 0.5.19 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | >=2.3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_connector_sqs"></a> [cloud\_connector\_sqs](#module\_cloud\_connector\_sqs) | ../../modules/infrastructure/cloudtrail-subscription-sqs |  |
| <a name="module_cloud_scanning_sqs"></a> [cloud\_scanning\_sqs](#module\_cloud\_scanning\_sqs) | ../../modules/infrastructure/cloudtrail-subscription-sqs |  |
| <a name="module_cloudtrail"></a> [cloudtrail](#module\_cloudtrail) | ../../modules/infrastructure/cloudtrail |  |
| <a name="module_codebuild"></a> [codebuild](#module\_codebuild) | ../../modules/infrastructure/codebuild |  |
| <a name="module_credentials_cloud_connector"></a> [credentials\_cloud\_connector](#module\_credentials\_cloud\_connector) | ../../modules/infrastructure/permissions/cloud-connector |  |
| <a name="module_credentials_cloud_scanning"></a> [credentials\_cloud\_scanning](#module\_credentials\_cloud\_scanning) | ../../modules/infrastructure/permissions/cloud-scanning |  |
| <a name="module_credentials_general"></a> [credentials\_general](#module\_credentials\_general) | ../../modules/infrastructure/permissions/general |  |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | ../../modules/infrastructure/resource-group |  |
| <a name="module_ssm"></a> [ssm](#module\_ssm) | ../../modules/infrastructure/ssm |  |

## Resources

| Name | Type |
|------|------|
| [helm_release.cloud_connector](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cloud_scanning](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sysdig_secure_api_token"></a> [sysdig\_secure\_api\_token](#input\_sysdig\_secure\_api\_token) | Sysdig Secure API token | `string` | n/a | yes |
| <a name="input_cloudtrail_is_multi_region_trail"></a> [cloudtrail\_is\_multi\_region\_trail](#input\_cloudtrail\_is\_multi\_region\_trail) | true/false whether cloudtrail will ingest multiregional events. testing/economization purpose. | `bool` | `true` | no |
| <a name="input_cloudtrail_kms_enable"></a> [cloudtrail\_kms\_enable](#input\_cloudtrail\_kms\_enable) | true/false whether s3 should be encrypted. testing/economization purpose. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances | `string` | `"sfc"` | no |
| <a name="input_region"></a> [region](#input\_region) | Default region for resource creation in both organization master and secure-for-cloud member account | `string` | `"eu-central-1"` | no |
| <a name="input_sysdig_secure_endpoint"></a> [sysdig\_secure\_endpoint](#input\_sysdig\_secure\_endpoint) | Sysdig Secure API endpoint | `string` | `"https://secure.sysdig.com"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | sysdig secure-for-cloud tags | `map(string)` | <pre>{<br>  "product": "sysdig-secure-for-cloud"<br>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.

# Sysdig Secure for Cloud in AWS :: Shared Organizational Trail

Deploy Sysdig Secure for Cloud sharing the Trail within an organization.
* In the **master account**
  * An Organizational Cloutrail will be deployed
  * When an account becomes part of an organization, AWS will create an `OrganizationAccountAccessRole` [for account management](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_access.html), which Sysdig Secure for Cloud will use for member-account provisioning.
  <br/>This Role is hardcoded ATM
* In the **user-provided member account**:
    * An additional role `SysdigSecureForCloudRole` will be created within the master account, to be able to read cloudtrail-s3 bucket events
    * All the Sysdig Secure for Cloud service-related resources will be created

![organizational diagram](https://raw.githubusercontent.com/sysdiglabs/terraform-aws-secure-for-cloud/b95bf11fe513bda3c037144803d982a6e4225ce9/examples/organizational/diagram-org.png)

## Prerequisites

Minimum requirements:

1.  Have an existing AWS account as the organization master account
    * Organizational CloudTrail service must be enabled
1.  AWS profile credentials configuration of the `master` account of the organization
    * This account credentials must be [able to manage cloudtrail creation](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/creating-trail-organization.html)
      > You must be logged in with the management account for the organization to create an organization trail. You must also have sufficient permissions for the IAM user or role in the management account to successfully create an organization trail.
    * Sysdig Secure for Cloud organizational member account id, as input variable value
        ```
       sysdig_secure_for_cloud_member_account_id=<ORGANIZATIONAL_SECURE_FOR_CLOUD_ACCOUNT_ID>
        ```
1. Secure requirements, as input variable value
    ```
    sysdig_secure_api_token=<SECURE_API_TOKEN>
    ```

## Usage

For quick testing, use this snippet on your terraform files

```terraform
module "secure_for_cloud_organizational" {
  source = "sysdiglabs/secure-for-cloud/aws//examples/organizational"

  sysdig_secure_api_token                     = "00000000-1111-2222-3333-444444444444"
  sysdig_secure_for_cloud_member_account_id   = "<ORG_MEMBER_ACCOUNT_FOR_SYSDIG_SECURE_FOR_CLOUD>"
}
```

See [inputs summary](#inputs) or module [`variables.tf`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/examples/organizational/variables.tf) file for more optional configuration.

To run this example you need have your [aws master-account profile configured in CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) and to execute:
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
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig) | >= 0.5.19 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.member"></a> [aws.member](#provider\_aws.member) | >= 3.50.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_connector"></a> [cloud\_connector](#module\_cloud\_connector) | ../../modules/services/cloud-connector |  |
| <a name="module_cloud_scanning"></a> [cloud\_scanning](#module\_cloud\_scanning) | ../../modules/services/cloud-scanning |  |
| <a name="module_cloudtrail"></a> [cloudtrail](#module\_cloudtrail) | ../../modules/infrastructure/cloudtrail |  |
| <a name="module_codebuild"></a> [codebuild](#module\_codebuild) | ../../modules/infrastructure/codebuild |  |
| <a name="module_ecs_fargate_cluster"></a> [ecs\_fargate\_cluster](#module\_ecs\_fargate\_cluster) | ../../modules/infrastructure/ecs-fargate-cluster |  |
| <a name="module_resource_group_master"></a> [resource\_group\_master](#module\_resource\_group\_master) | ../../modules/infrastructure/resource-group |  |
| <a name="module_resource_group_secure_for_cloud_member"></a> [resource\_group\_secure\_for\_cloud\_member](#module\_resource\_group\_secure\_for\_cloud\_member) | ../../modules/infrastructure/resource-group |  |
| <a name="module_secure_for_cloud_role"></a> [secure\_for\_cloud\_role](#module\_secure\_for\_cloud\_role) | ../../modules/infrastructure/organizational/secure-for-cloud-role |  |
| <a name="module_ssm"></a> [ssm](#module\_ssm) | ../../modules/infrastructure/ssm |  |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.connector_ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_policy_document.task_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sysdig_secure_api_token"></a> [sysdig\_secure\_api\_token](#input\_sysdig\_secure\_api\_token) | Sysdig Secure API token | `string` | n/a | yes |
| <a name="input_sysdig_secure_for_cloud_member_account_id"></a> [sysdig\_secure\_for\_cloud\_member\_account\_id](#input\_sysdig\_secure\_for\_cloud\_member\_account\_id) | organizational member account where the secure-for-cloud workload is going to be deployed | `string` | n/a | yes |
| <a name="input_cloudtrail_is_multi_region_trail"></a> [cloudtrail\_is\_multi\_region\_trail](#input\_cloudtrail\_is\_multi\_region\_trail) | testing/economization purpose. true/false whether cloudtrail will ingest multiregional events | `bool` | `true` | no |
| <a name="input_cloudtrail_kms_enable"></a> [cloudtrail\_kms\_enable](#input\_cloudtrail\_kms\_enable) | testing/economization purpose. true/false whether s3 should be encrypted | `bool` | `true` | no |
| <a name="input_connector_ecs_task_role_name"></a> [connector\_ecs\_task\_role\_name](#input\_connector\_ecs\_task\_role\_name) | Name for the ecs task role. This is only required to resolve cyclic dependency with organizational approach | `string` | `"cloudconnector-ECSTaskRole"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the Cloud Vision deployment | `string` | `"sysdig-secure-for-cloud"` | no |
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

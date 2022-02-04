# Sysdig Secure for Cloud in AWS<br/>[ Example :: Shared Organizational Trail ]

Deploy Sysdig Secure for Cloud sharing the Trail within an organization.

* In the **management account**
  * An Organizational Cloutrail will be deployed  (with required S3,SNS)
  * An additional role `SysdigSecureForCloudRole` will be created
     * to be able to read cloudtrail-s3 bucket events from sysdig workload member account.
     * will also be used to asummeRole over other roles, and enable the process of scanning on ECR's that may be present in other member accounts.
* In the **user-provided member account**
    * All the Sysdig Secure for Cloud service-related resources will be created

![organizational diagram](https://raw.githubusercontent.com/sysdiglabs/terraform-aws-secure-for-cloud/5b7cf5e8028b3177536c9c847020ad6319342b44/examples/organizational/diagram-org.png)

## Prerequisites

Minimum requirements:

1. Have an existing AWS account as the organization management account
    * Organizational CloudTrail service must be enabled
    * [Organizational CloudFormation StackSets](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/stacksets-orgs-enable-trusted-access.html) service must be enabled
1. Configure [Terraform **AWS** Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) for the `management` account of the organization
    * This provider credentials must be [able to manage cloudtrail creation](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/creating-trail-organization.html)
      > You must be logged in with the management account for the organization to create an organization trail. You must also have sufficient permissions for the IAM user or role in the management account to successfully create an organization trail.
    * When an account is created within an organization, AWS will create an `OrganizationAccountAccessRole` [for account management](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_access.html), which Sysdig Secure for Cloud will use for member-account provisioning and role assuming.
    * However, when the account is invited into the organization, it's required to [create the role manually](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_access.html#orgs_manage_accounts_create-cross-account-role)
       > You have to do this manually, as shown in the following procedure. This essentially duplicates the role automatically set up for created accounts. We recommend that you use the same name, OrganizationAccountAccessRole, for your manually created roles for consistency and ease of remembering.
    * This role name, `OrganizationAccountAccessRole`, is currently hardcoded on the module.
3. Provide a member **account ID for Sysdig Secure for Cloud workload** to be deployed.
   Our recommendation is for this account to be empty, so that deployed resources are not mixed up with your workload.
   This input must be provided as terraform required input value
    ```
    sysdig_secure_for_cloud_member_account_id=<ORGANIZATIONAL_SECURE_FOR_CLOUD_ACCOUNT_ID>
    ```
4. **Sysdig Secure** requirements, as input variable value with the `api-token`
    ```
    sysdig_secure_api_token=<SECURE_API_TOKEN>
    ```

## Usage

For quick testing, use this snippet on your terraform files

```terraform
provider "aws" {
  region = "<AWS_REGION>; ex. us-east-1"
}

module "secure_for_cloud_organizational" {
  source = "sysdiglabs/secure-for-cloud/aws//examples/organizational"

  sysdig_secure_api_token                     = "00000000-1111-2222-3333-444444444444"
  sysdig_secure_for_cloud_member_account_id   = "<ORG_MEMBER_ACCOUNT_FOR_SYSDIG_SECURE_FOR_CLOUD>"
}
```

See [inputs summary](#inputs) or module [`variables.tf`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/examples/organizational/variables.tf) file for more optional configuration.

To run this example you need have your [aws management-account profile configured in CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) and to execute:
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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.62.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig) | >= 0.5.19 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.62.0 |
| <a name="provider_aws.member"></a> [aws.member](#provider\_aws.member) | >= 3.62.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_bench"></a> [cloud\_bench](#module\_cloud\_bench) | ../../modules/services/cloud-bench |  |
| <a name="module_cloud_connector"></a> [cloud\_connector](#module\_cloud\_connector) | ../../modules/services/cloud-connector |  |
| <a name="module_cloudtrail"></a> [cloudtrail](#module\_cloudtrail) | ../../modules/infrastructure/cloudtrail |  |
| <a name="module_codebuild"></a> [codebuild](#module\_codebuild) | ../../modules/infrastructure/codebuild |  |
| <a name="module_ecs_vpc_secgroup"></a> [ecs\_vpc\_secgroup](#module\_ecs\_vpc\_secgroup) | ../../modules/infrastructure/ecs-vpc-secgroup |  |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | ../../modules/infrastructure/resource-group |  |
| <a name="module_resource_group_secure_for_cloud_member"></a> [resource\_group\_secure\_for\_cloud\_member](#module\_resource\_group\_secure\_for\_cloud\_member) | ../../modules/infrastructure/resource-group |  |
| <a name="module_secure_for_cloud_role"></a> [secure\_for\_cloud\_role](#module\_secure\_for\_cloud\_role) | ../../modules/infrastructure/permissions/org-role-ecs |  |
| <a name="module_ssm"></a> [ssm](#module\_ssm) | ../../modules/infrastructure/ssm |  |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.connector_ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_policy_document.task_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sysdig_secure_api_token"></a> [sysdig\_secure\_api\_token](#input\_sysdig\_secure\_api\_token) | Sysdig Secure API token | `string` | n/a | yes |
| <a name="input_sysdig_secure_for_cloud_member_account_id"></a> [sysdig\_secure\_for\_cloud\_member\_account\_id](#input\_sysdig\_secure\_for\_cloud\_member\_account\_id) | organizational member account where the secure-for-cloud workload is going to be deployed | `string` | n/a | yes |
| <a name="input_benchmark_regions"></a> [benchmark\_regions](#input\_benchmark\_regions) | List of regions in which to run the benchmark. If empty, the task will contain all aws regions by default. | `list(string)` | `[]` | no |
| <a name="input_cloudtrail_is_multi_region_trail"></a> [cloudtrail\_is\_multi\_region\_trail](#input\_cloudtrail\_is\_multi\_region\_trail) | true/false whether cloudtrail will ingest multiregional events. testing/economization purpose. | `bool` | `true` | no |
| <a name="input_cloudtrail_kms_enable"></a> [cloudtrail\_kms\_enable](#input\_cloudtrail\_kms\_enable) | true/false whether cloudtrail delivered events to S3 should persist encrypted | `bool` | `true` | no |
| <a name="input_cloudtrail_s3_arn"></a> [cloudtrail\_s3\_arn](#input\_cloudtrail\_s3\_arn) | ARN of a pre-existing cloudtrail\_sns s3 bucket. Used together with `cloudtrail_sns_arn`, `cloudtrail_s3_arn`. If it does not exist, it will be inferred from create cloudtrail | `string` | `"create"` | no |
| <a name="input_cloudtrail_sns_arn"></a> [cloudtrail\_sns\_arn](#input\_cloudtrail\_sns\_arn) | ARN of a pre-existing cloudtrail\_sns. Used together with `cloudtrail_sns_arn`, `cloudtrail_s3_arn`. If it does not exist, it will be inferred from created cloudtrail. Providing an ARN requires permisision to SNS:Subscribe, check ./modules/infrastructure/cloudtrail/sns\_permissions.tf block | `string` | `"create"` | no |
| <a name="input_connector_ecs_task_role_name"></a> [connector\_ecs\_task\_role\_name](#input\_connector\_ecs\_task\_role\_name) | Name for the ecs task role. This is only required to resolve cyclic dependency with organizational approach | `string` | `"organizational-ECSTaskRole"` | no |
| <a name="input_deploy_benchmark"></a> [deploy\_benchmark](#input\_deploy\_benchmark) | Whether to deploy or not the cloud benchmarking | `bool` | `true` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | Name of a pre-existing ECS (elastic container service) cluster. If defaulted, a new ECS cluster/VPC/Security Group will be created. For both options, ECS location will/must be within the `sysdig_secure_for_cloud_member_account_id` parameter accountID | `string` | `"create"` | no |
| <a name="input_ecs_vpc_id"></a> [ecs\_vpc\_id](#input\_ecs\_vpc\_id) | ID of the VPC where the workload is to be deployed. Defaulted to be created when `ecs_cluster_name is not provided.` | `string` | `"create"` | no |
| <a name="input_ecs_vpc_region_azs"></a> [ecs\_vpc\_region\_azs](#input\_ecs\_vpc\_region\_azs) | List of Availability Zones for ECS VPC creation. e.g.: ["apne1-az1", "apne1-az2"]. If defaulted, two of the default 'aws\_availability\_zones' datasource will be taken | `list(string)` | `[]` | no |
| <a name="input_ecs_vpc_subnets_private_ids"></a> [ecs\_vpc\_subnets\_private\_ids](#input\_ecs\_vpc\_subnets\_private\_ids) | List of VPC subnets where workload is to be deployed. Defaulted to be created when `ecs_cluster_name is not provided.` | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances | `string` | `"sfc"` | no |
| <a name="input_organizational_member_default_admin_role"></a> [organizational\_member\_default\_admin\_role](#input\_organizational\_member\_default\_admin\_role) | Default role created by AWS for managed-account users to be able to admin member accounts.<br/>https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_access.html | `string` | `"OrganizationAccountAccessRole"` | no |
| <a name="input_sysdig_secure_endpoint"></a> [sysdig\_secure\_endpoint](#input\_sysdig\_secure\_endpoint) | Sysdig Secure API endpoint | `string` | `"https://secure.sysdig.com"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | sysdig secure-for-cloud tags | `map(string)` | <pre>{<br>  "product": "sysdig-secure-for-cloud"<br>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.

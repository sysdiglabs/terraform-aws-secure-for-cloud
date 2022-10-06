# Secure for Cloud for AWS Use-Cases

Use the [questionnaire](./_questionnaire.md) to let us know your needs

## Use-Case summary

WIP
- current examples
- current use-cases

## Example Selection


|                   | Single  `single-`                                                          |  Organizational `organizational-` |
| --| -- | -- |
| Deployment Type   | all Sysdig resources will be deployed within the selected account |  most Sysdig resources will be deployed within the selected account, but some require to be deployed on member-accounts (for Compliance and Image Scanning) and one role is needed on the management account for cloudtrail event access |
| Target          | will only analyse current account                                 |  handles all accounts (managed and member)
| Drawbacks         | cannot re-use another account Cloudtrail data (unless its deployed on the same account where the sns/s3 bucket is) | for scanning, a per-member-account access role is required

With both examples `single` and `org`, you can customize the desired features to de deployed with the `deploy_*` input vars to avoid deploying more than wanted.

<br/>

### Compute Workload Type

| Cloud | Example Options |
| - | - |
| AWS | K8S `-k8s`, ECS `-ecs`, AppRunner `-apprunner` |
| GCP | K8S `-k8s`, CloudRun |
| Azure | K8S `-k8s`, AzureContainerInstances |

<br/><br/>

## Available Optionals

We enable following optionals, to allow user to re-use their pre-existing / configured resources.

|  Cloud |  Optionals | Related Input Vars | Other |
| -- | --| -- | -- |
| AWS  | Cloudtrail | single: [`cloudtrail_sns_arn`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/single-account-ecs#input_cloudtrail_sns_arn)<br/>organizational: [`existing_cloudtrail_config`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/organizational#input_existing_cloudtrail_config) | - |
| | ECS, VPC, Subnet | `ecs_cluster_name`, `ecs_vpc_id`, `ecs_vpc_subnets_private_ids` | if used, the three are mandatory  |
| GCP | - | - | - |
| Azure | ResourceGroup | `resource_group_name` | - |
| | ACR | `registry_name`, `registry_resource_group_name` | - |
| * | Compute Workload | - | All clouds allow Sysdig Secure for cloud to be deployed on a pre-existing K8S cluster|
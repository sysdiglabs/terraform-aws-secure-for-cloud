# Secure for Cloud for AWS Use-Cases

Secure for cloud is served through Terraform for [AWS](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud)
[GCP](https://github.com/sysdiglabs/terraform-google-secure-for-cloud) and [Azure](https://github.com/sysdiglabs/terraform-azurerm-secure-for-cloud) clouds,
and for AWS in [Cloudformation](https://github.com/sysdiglabs/aws-templates-secure-for-cloud) too.

### Compute Workload Type

| Cloud | Example Options |
| - | - |
| AWS | K8S `-k8s`, ECS `-ecs`, AppRunner `-apprunner` |
| GCP | K8S `-k8s`, CloudRun |
| Azure | K8S `-k8s`, AzureContainerInstances |

**Which should I choose?**
<br/>There are no preffered way, just take a technology you're familiar with. Otherwise, prefer non K8S, as it will be harder to maintain.
<br/>For AWS, beware of [AppRunner region limitations](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/examples/single-account-apprunner/README.md#prerequisites)
<br/><br/>


## Available Optionals

Make use of optionals to allow the re-use of pre-existing resources, and avoid incurring in more costs.

|  Cloud |  Optionals | Related Input Vars | Other |
| -- | --| -- | -- |
| AWS  | Cloudtrail | single: [`cloudtrail_sns_arn`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/single-account-ecs#input_cloudtrail_sns_arn)<br/>organizational: [`existing_cloudtrail_config`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/organizational#input_existing_cloudtrail_config) |  For organizational example, optional resources must exist in the management account. For other setups check other alternative use-cases |
| | ECS, VPC, Subnet | `ecs_cluster_name`, `ecs_vpc_id`, `ecs_vpc_subnets_private_ids` | if used, the three are mandatory  |
| GCP | - | - | - |
| Azure | ResourceGroup | `resource_group_name` | - |
| | ACR | `registry_name`, `registry_resource_group_name` | - |
| * | Compute Workload | - | All clouds allow Sysdig Secure for cloud to be deployed on a pre-existing K8S cluster|


<br/><br/>

## Use-Case summary


Current examples were developed for simple use-case scenarios.
<br/>New use-cases are appearing and once we consolidate a standard scenario, we will create new examples to accommodate new requirements.
<br/>Check current use-case list or use the [questionnaire](./_questionnaire.md) to let us know your needs.

If not Terraform nor Cloudformation suits, take a look at the `manual-*` prefixed use-cases.



For [all-feature installation](https://docs.sysdig.com/en/docs/sysdig-secure/sysdig-secure-for-cloud/#features), check


|                   | `/examples/single-*`                                               | `/examples/organizational-*` |
| --| -- | -- |
| Deployment Type   | all Sysdig resources will be deployed within the selected account | Most Sysdig resources will be deployed within the selected account (just one), but some features, require resources to be deployed on all of the member-accounts (for Compliance and Image Scanning) . <br />One role is needed on the management account for cloudtrail-s3 event access |
| Target          | will only analyse current account                                 |  handles all accounts (managed and member)|
| Drawbacks         | cannot re-use another account Cloudtrail data (unless its deployed on the same account where the sns/s3 bucket is) | for scanning, a per-member-account access role is required |
| Optional resources usage limitations | - |  For organizational example, Cloudtrail optional resources must exist in the management account. For other setups check other alternative use-cases</br><ul><li>[manual deployment; cloudtrail-s3 bucket in another member account](./manual-org-three-way.md)</li><li>[terraform-based deployment; cloudtrail with cloudtrail-s3 bucket in another member account. k8s flavor](./org-three-way-k8s.md)</li><li>[terraform-based deployment; cloudtrail with cloudtrail-s3 bucket in another member account. ecs flavor](./org-three-way-ecs.md)</li></ul>|
| More Info | [single-ecs](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/single-account-ecs), [single-apprunner](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/single-account-apprunner), [single-k8s](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/single-account-k8s) | [organizational](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/organizational) |

With both examples `single` and `org`, you can customize the desired features to de deployed with the `deploy_*` input vars to avoid deploying more than wanted.

<br/>
If you just want [CIS Unified Compliance Benchmarks](https://docs.sysdig.com/en/docs/sysdig-secure/posture/compliance/compliance-unified-/) 
you can make use of 
- [Single-Account Compliance Role Setup](./single-compliance-role.md)
- [Organizational Compliance Role setup](./organizational-compliance-role.md)
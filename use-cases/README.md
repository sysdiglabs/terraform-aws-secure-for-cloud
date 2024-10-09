# Secure for Cloud Use Cases

## Cloud Platforms

### Feature Summary

| Cloud | Single Setup | Organizational Setup              | Event Source                                     | Compute Deployment Options                     | Sysdig Role Setup              | Image Scanning Options                                 | Spawned Scanning Service |
|-------|--------------|-----------------------------------|--------------------------------------------------|------------------------------------------------|--------------------------------|--------------------------------------------------------|--------------------------|
| AWS   | Account      | Organization with member accounts | Cloudtrail                                       | K8S `-k8s`, ECS `-ecs`, AppRunner `-apprunner` | IAM Role with Trusted Identity | ECS deployed images,<br/>ECR, Public Repositories      | Codebuild project        |
| GCP   | Project      | Organization with member projects | Project/Organization Sink,<br/> GCR PubSub Topic | K8S `-k8s`, CloudRun                           | Workload Identity Federation   | CloudRun deployed images,<br/>GCR, Public Repositories | Cloudbuild task          |
| Azure | Subscription | Tenant subscriptions              | EventHub, Eventgrid                              | K8S `-k8s`, AzureContainerInstances (ACI)      | Azure Lighthouse               | ACI deployed images,<br/> ACR, Public Repositories     | ACR Task                 |


### Which Compute Deployment Should I Choose?

There are no preferred way, just take a technology you're familiar with. Otherwise, prefer non-K8S, as it will be harder to maintain.
For AWS, beware of [AppRunner region limitations](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/examples/single-account-apprunner/README.md#prerequisites).


### Pre-Existing Resource Usage

Make use of optionals to reuse pre-existing resources and prevent incurring in more costs.

| Cloud | Optionals        | Related Input Vars                                                                                                                                                                                                                                                                                                                                  | Other                                                                                                                                   |
|-------|------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------|
| AWS   | Cloudtrail       | single: [`cloudtrail_sns_arn`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/single-account-ecs#input_cloudtrail_sns_arn)<br/>organizational: [`existing_cloudtrail_config`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/organizational#input_existing_cloudtrail_config) | For organizational example, optional resources must exist in the management account. For other setups check other alternative use-cases |
|       | ECS, VPC, Subnet | `ecs_cluster_name`, `ecs_vpc_id`, `ecs_vpc_subnets_private_ids`                                                                                                                                                                                                                                                                                     | if used, the three are mandatory                                                                                                        |
| GCP   | -                | -                                                                                                                                                                                                                                                                                                                                                   | -                                                                                                                                       |
| Azure | ResourceGroup    | `resource_group_name`                                                                                                                                                                                                                                                                                                                               | -                                                                                                                                       |
|       | ACR              | `registry_name`, `registry_resource_group_name`                                                                                                                                                                                                                                                                                                     | -                                                                                                                                       |
| *     | Compute Workload | -                                                                                                                                                                                                                                                                                                                                                   | All clouds allow Sysdig Secure for cloud to be deployed on a pre-existing K8S cluster                                                   |

### Overview

Current examples were developed for simple scenarios.
As new use cases emerge, we will establish a standard scenario and create new examples to accommodate additional requirements.
Check the current list of use cases or use the [questionnaire](./_questionnaire.md) to let us know your needs.

If Terraform or Cloudformation suits your purpose, take a look at the `manual-*` prefixed use cases.

## AWS-Specific Guidelines

Secure for cloud is installed in AWS either by using [terraform](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud) or by using a [Cloudformation](https://github.com/sysdiglabs/aws-templates-secure-for-cloud) template.

### Features

For [complete feature installation](https://docs.sysdig.com/en/docs/sysdig-secure/sysdig-secure-for-cloud/#features), check


|                   | `/examples/single-*`                                               | `/examples/organizational-*` |
| --| -- | -- |
| Deployment Type   | all Sysdig resources will be deployed within the selected account | Most Sysdig resources will be deployed within the selected account (just one), but some features, require resources to be deployed on all of the member-accounts (for Compliance and Image Scanning) . <br />One role is needed on the management account for cloudtrail-s3 event access |
| Target          | will only analyse current account                                 |  handles all accounts (managed and member) + dynamically created new member accounts|
| Drawbacks         | cannot re-use another account Cloudtrail data (unless its deployed on the same account where the sns/s3 bucket is) | for scanning, a per-member-account access role is required |
| Optional resources usage limitations | - |  For organizational example, Cloudtrail resources cloudtrail-s3 and cloudtrail-sns, must exist in the management account. For other setups check other alternative use-cases</br><ul><li>[manual deployment; cloudtrail-s3 bucket in another member account](./manual-org-three-way.md)</li><li>[terraform-based deployment; cloudtrail with cloudtrail-s3 bucket in another member account. k8s flavor](./org-three-way-k8s.md)</li><li>[terraform-based deployment; cloudtrail with cloudtrail-s3 bucket in another member account. ecs flavor](./org-three-way-ecs.md)</li><li>[terraform-based; re-use ecs/vpc/subnet](./org-existing-cloudtrail-ecs-vpc-subnet.md)</li></ul>|
| More Info | [AWS single-ecs](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/single-account-ecs), [AWS single-apprunner](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/single-account-apprunner), [AWS single-k8s](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/single-account-k8s) | [AWS organizational](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/organizational) |

With both examples `single` and `org`, you can customize the desired features to de deployed with the `deploy_*` input vars to avoid deploying more than wanted.

### Unified Compliance

If you just want [CIS Unified Compliance Benchmarks](https://docs.sysdig.com/en/docs/sysdig-secure/posture/compliance/compliance-unified-/)
see [Compliance role-only deployment with Terraform](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/deploy-sysdig-secure-for-cloud-agentless/)
<br/>Alternatively, you can [configure it manually](./manual-compliance.md)

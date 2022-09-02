# Use-Case Questionnaire

This questionnaire is aimed to help you/us find the most suitable way of deploying [Sysdig Secure for Cloud](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/).

Despite wanting only to trial it, we suggest that you deploy, and test it, in th **most-similar situation to what
you have on your production environment**.

We are aware that current examples don't suit all situations, and we will keep improving them to be as configurable as possible.
Contact us with these questions answered to help us.

<br/>

Sysdig Secure for Cloud is served in Terraform [AWS](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud), [GCP](https://github.com/sysdiglabs/terraform-google-secure-for-cloud) and [Azure](https://github.com/sysdiglabs/terraform-azurerm-secure-for-cloud)
modules, and we also offer [AWS Cloudformation templates](https://github.com/sysdiglabs/aws-templates-secure-for-cloud)

<br/>

## Client Infrastructure

- does your company work under an **organization** (AWS/GCP) or tenant (Azure)?
  - if so, how many member accounts (aws) /projects (gcp) /subscriptions (azure) does it have?
    - regarding of the number, how many accounts would be required to enroll in the secure for cloud setup?
    - do you have dynamic accounts/projects/subscriptions? what's their lifecycle?
  - does it have any landing such as aws control-tower?
- sysdig secure for cloud is presented in different **compute workload** flavors; ecs on aws, cloudrun on gcp or azure container instances on azure, plus a K8s deployment an all three clouds, plus apprunner on aws (less resource-demaing than ecs, but region limited)
    - in case of ECS or K8S, do you have an existing cluster you would like to re-use?
- (aws-only) do you have **existing aws cloudtrail**?
    - is it an organizational cloudtrail?
      - does the cloudtrail report to an SNS? if no, could you enable it? ingestor-type: `aws-cloudtrail-sns-sqs`
      - is the S3 bucket of that cloudtrail in the management account or a sepparated member account?
    - if it's not organizational, does each trail report to the same s3 bucket?
      - if so, does that S3 bucket already have any "Event Notification System"? Is it an SNS we could subscribe to? ingestor-type: `aws-cloudtrail-s3-sns-sqs`
      - if so, does that S3 bucket already have an "Amazon EventBridge" system activated? ingestor-type: `aws-cloudtrail-s3-sns-sqs-eventbridge`
    - whether it's organizational or not, could you give us a quick picture of the account setup in terms of purpose?
- how many **regions** do you work with?
    - is secure for cloud to be deployed on the same region as your existing resources?
    -   if not, explain us your current region setup
    - (aws-only) if in previous point you said you have a cloudtrail, cloudtrail-sns, or cloudtrail-s3, in which region is it?
- how do you handle **IAM permissions**? would you let our Terraform scripts set them up for you, or you want to set them yourself manually? any restriction we may be aware of?
- how do you handle **outbound newtwork connection** securization? does your infrastructure have any customized VPC/firewally setup?
- **Deployment** type
  - are you familiar with the installation stack? Terraform, Cloudformation, AWS CDK, ...? Do you use any other InfraAsCode frameworks?
  - if you want to use Kubernetes compute for Sysdig deployment, what's your current way of deploying helm charts?

<br/>

## Sysdig Features

In what [Sysdig For Cloud Features](https://docs.sysdig.com/en/docs/sysdig-secure/sysdig-secure-for-cloud/) are you interested in?

- [Runtime Threat Detection](https://docs.sysdig.com/en/docs/sysdig-secure/insights/)
- [Compliance](https://docs.sysdig.com/en/docs/sysdig-secure/posture/compliance/compliance-unified-/) (cis benchmarks and others)
- [Identity and Access Management](https://docs.sysdig.com/en/docs/sysdig-secure/posture/permissions-and-entitlements/)
- Scanning
  - Push-based registry/repository image scanning
  - Runtime workload image scanning (ecs on Aws, cloudrun on GCP, or container instances on Azure)
  - Note: Sysdig offers many other ways of performing scanning, and we recommend you to [Check all Scanning options in the Vulnerability Management](https://docs.sysdig.com/en/docs/sysdig-secure/vulnerabilities/) to push this task as far to the left as possible (dev side)


<br/><br/>

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

# Use-Case Questionnaire

This questionnaire is aimed to help you/us find the most suitable way of deploying [Sysdig Secure for Cloud](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/) in your infrastucture, as well as to understand the needs to develop new  official `/examples`, for reducing the installation friction.

Despite wanting only to trial it, we suggest that you deploy, and test it, in th **most-similar situation to what
you have on your production environment**.

We are aware that current examples don't suit all situations, and we will keep improving them to be as configurable as possible.
Contact us with these questions answered to help us.

<br/>

Sysdig Secure for Cloud is served in Terraform [AWS](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud), [GCP](https://github.com/sysdiglabs/terraform-google-secure-for-cloud) and [Azure](https://github.com/sysdiglabs/terraform-azurerm-secure-for-cloud)
modules, and we also offer [AWS Cloudformation templates](https://github.com/sysdiglabs/aws-templates-secure-for-cloud)

<br/>

## Client Infrastructure

### aws-specific
- do you have **existing aws cloudtrail**?
    - is it an organizational cloudtrail in the organization management account?
      - does this organizational cloudtrail report to an SNS? if yes, is it in the same management account? if no, could you enable it?  ingestor-type: `aws-cloudtrail-sns-sqs`
      - is the S3 bucket of that cloudtrail in the management account or a sepparated member account?
    - if it's not organizational, does each trail report to the same s3 bucket?
      - if so, does that S3 bucket already have any "Event Notification System"? Is it an SNS we could subscribe to? ingestor-type: `aws-cloudtrail-s3-sns-sqs`
      - if so, does that S3 bucket already have an "Amazon EventBridge" system activated? ingestor-type: `aws-cloudtrail-s3-sns-sqs-eventbridge`
- whether it's organizational or not, could you give us a quick picture of the infra setup in terms of what resource is in what account? the resources of interest are the ones you may want to reuse, such as the cloudtrail, cloudtrail-sns, cloudtrail-s3, existing clusters where to deploy the workload, ...


### general
- does your company work under an **organization** (AWS/GCP) or tenant (Azure)?
  - if so, how many member accounts (aws) /projects (gcp) /subscriptions (azure) does it have?
    - regarding of the number, how many accounts would be required to enroll in the secure for cloud setup?
    - do you have dynamic accounts/projects/subscriptions? what's their lifecycle?
  - does it have any landing such as aws control-tower? what's event management there (if any)?
- sysdig secure for cloud is presented in different **compute workload** flavors; ecs on aws, cloudrun on gcp or azure container instances on azure, plus a K8s deployment an all three clouds, plus apprunner on aws (less resource-demaing than ecs, but region limited)
    - in case of ECS or K8S, do you have an existing cluster you would like to re-use?
- how many **regions** do you work with?
    - if more than one, could you briefly explain the region usage/setup?
    - secure for cloud requires both s3 and cloudtrail-sns to be deployed in the same region. would that apply to the use-case?
    - in case of AWS ECS deployment, it have to be done in the same previous region. would that be a problem?
- how do you handle **IAM permissions**? would you let our Terraform scripts set them up for you, or you want to set them yourself manually? any restriction we may be aware of?
- how do you handle **outbound newtwork connection** securization? does your infrastructure have any customized VPC/firewally setup?
- **Deployment** type
  - are you familiar with the installation stack? Terraform, Cloudformation, AWS CDK, ...? would you have any preference?
  - do you use any other InfraAsCode frameworks?
  - if you want to use Kubernetes compute for Sysdig deployment, what's your current way of deploying helm charts?

<br/>

## Sysdig Features

In what [Sysdig For Cloud Features](https://docs.sysdig.com/en/docs/sysdig-secure/sysdig-secure-for-cloud/) are you interested in?

- [Runtime Threat Detection](https://docs.sysdig.com/en/docs/sysdig-secure/insights/)
- [Compliance](https://docs.sysdig.com/en/docs/sysdig-secure/posture/compliance/compliance-unified-/) (cis benchmarks and others)
- [Identity and Access Management](https://docs.sysdig.com/en/docs/sysdig-secure/posture/permissions-and-entitlements/)
- [Scanning](https://docs.sysdig.com/en/docs/sysdig-secure/scanning/)
  - Registry/repository push-based image scanning
  - Runtime workload image scanning (ecs on Aws, cloudrun on GCP, or container instances on Azure)
  - Note: Sysdig offers many other ways of performing scanning, and we recommend you to [Check all Scanning options in the Vulnerability Management](https://docs.sysdig.com/en/docs/sysdig-secure/vulnerabilities/) to push this task as far to the left as possible (dev side)

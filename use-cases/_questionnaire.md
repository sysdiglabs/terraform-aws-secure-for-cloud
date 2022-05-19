# Use-Case Questionnaire

This questionnaire is aimed to help you/us find the most suitable way of deploying [Sysdig Secure for Cloud](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/).

Despite wanting only to trial it, we suggest that you deploy, and test it, in the most-similar situation to what
you have on your production environment.

We are aware that current examples don't suit all situations, and we will keep improving them to be as configurable as possible.
Contact us with these questions answered to help us.

> Sysdig Secure for Cloud is served in Terraform [AWS](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud), [GCP](https://github.com/sysdiglabs/terraform-google-secure-for-cloud) and [Azure](https://github.com/sysdiglabs/terraform-azurerm-secure-for-cloud)
modules, and we also offer [AWS Cloudformation templates](https://github.com/sysdiglabs/aws-templates-secure-for-cloud)

<br/><br/>

## Client Infrastructure

- does your company work under an organization (AWS/GCP) or tenant (Azure)?
  - if so, how many member accounts (aws) /projects (gcp) /subscriptions (azure) does it have?
- deployment type
  - are you familiar with the installation stack? Terraform or Cloudformation?
  - if you want to use Kubernetes workload for Sysdig deployment, what's your current way of deploying helm charts?


### AWS
  - do you have an existing cloudtrail?
    - if yes, is it an organizational cloudtrail?
      - does the cloudtrail report to an SNS?
    - if it's not organizational, does each trail report to the same s3 bucket?
  - sysdig secure for cloud is presented in different workload flavor; ECS, K8S or Apprunner, would you have any preference?
    - in case of ECS or K8S, do you have an existing cluster you would like to re-use?


## Sysdig Features

In what [Sysdig For Cloud Features](https://docs.sysdig.com/en/docs/sysdig-secure/sysdig-secure-for-cloud/) are you interested in?

- [Runtime Threat Detection](https://docs.sysdig.com/en/docs/sysdig-secure/insights/)
- [Compliance](https://docs.sysdig.com/en/docs/sysdig-secure/posture/compliance/compliance-unified-/) (cis benchmarks and others)
- [Identity and Access Management](https://docs.sysdig.com/en/docs/sysdig-secure/posture/permissions-and-entitlements/)
- Scanning
  - Push-based registry/repository image scanning
  - Runtime workload image scanning (ecs on Aws, cloudrun on GCP, or container instances on Azure)
  - Note: Sysdig offers many other ways of performing scanning, and we recommend you to [Check all Scanning options in the Vulnerability Management](https://docs.sysdig.com/en/docs/sysdig-secure/vulnerabilities/)



## Example Selection

|                   | Single                                                            |  Organizational |
| --| -- | -- |
| Deployment Type   | All Sysdig resources will be deployed within the selected account |  Most Sysdig resources will be deployed within the selected account, but some require to be deployed on member-accounts (for Compliance and Image Scanning)
| Benefits          | Will only analyse current account                                 |  Handles all accounts (managed and member)
| Drawbacks         | Cannot re-use another account Cloudtrail data (unless its deployed on the same account where the sns/s3 bucket is) | --

With both examples `single` and `org`, you can customize the desired features to de deployed with the `deploy_*` input vars to avoid deploying more than wanted

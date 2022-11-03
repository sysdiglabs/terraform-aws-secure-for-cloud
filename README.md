# Sysdig Secure for Cloud in AWS

Terraform module that deploys the [**Sysdig Secure for Cloud** stack in **AWS**](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/deploy-sysdig-secure-for-cloud-on-aws).
<br/>

Provides unified threat-detection, compliance, forensics and analysis through these major components:

* **[Threat Detection](https://docs.sysdig.com/en/docs/sysdig-secure/insights/)**: Tracks abnormal and suspicious activities in your cloud environment based on Falco language. Managed through `cloud-connector` module. <br/>

* **[Compliance](https://docs.sysdig.com/en/docs/sysdig-secure/posture/compliance/compliance-unified-/)**: Enables the evaluation of standard compliance frameworks. Requires both modules  `cloud-connector` and `cloud-bench`. <br/>

* **[Identity and Access Management](https://docs.sysdig.com/en/docs/sysdig-secure/posture/identity-and-access/)**: Analyses user access overly permissive policies. Requires both modules  `cloud-connector` and `cloud-bench`. <br/>

* **[Image Scanning](https://docs.sysdig.com/en/docs/sysdig-secure/scanning/)**: Automatically scans all container images pushed to the registry (ECR) and the images that run on the AWS workload (currently ECS). Managed through `cloud-connector`. <br/>Disabled by Default, can be enabled through `deploy_image_scanning_ecr` and `deploy_image_scanning_ecs` input variable parameters.<br/>

For other Cloud providers check: [GCP](https://github.com/sysdiglabs/terraform-google-secure-for-cloud), [Azure](https://github.com/sysdiglabs/terraform-azurerm-secure-for-cloud)

<br/>


## Usage

There are several ways to deploy Secure for Cloud in you AWS infrastructure,
- **[`/examples`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples)** for the most common scenarios
  - [Single Account on ECS](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/single-account-ecs/)
  - [Single Account on AppRunner](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/single-account-apprunner/)
  - [Single-Account with a pre-existing Kubernetes Cluster](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/single-account-k8s/)
  - [Organizational](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/organizational/)
  - Many module,examples and use-cases, we provide ways to **re-use existing resources (as optionals)** in your
    infrastructure. Check input summary on each example/module.

- **[`/use-cases`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/use-cases)** with self-baked customer-specific alternative scenarios.
<br/>

Find specific overall service arquitecture diagrams attached to each example/use-case.

In the long-term our purpose is to evaluate those use-cases and if they're common enough, convert them into examples to make their usage easier.

If you're unsure about what/how to use this module, please fill the [questionnaire](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/use-cases/_questionnaire.md) report as an issue and let us know your context, we will be happy to help.

### Notice

* [AWS regions](https://docs.aws.amazon.com/general/latest/gr/rande.html#regional-endpoints)
* **Resource creation inventory** Find all the resources created by Sysdig examples in the resource-group `sysdig-secure-for-cloud` (AWS Resource Group & Tag Editor) <br/>
* All Sysdig Secure for Cloud features but [Image Scanning](https://docs.sysdig.com/en/docs/sysdig-secure/scanning/) are enabled by default. You can enable it through `deploy_scanning` input variable parameters.<br/>
  - **Management Account ECR image scanning** is not support since it's [not a best practice](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_best-practices_mgmt-acct.html#best-practices_mgmt-use) to have an ECR in the management account. However, we have a workaround to [solve this problem](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud#q-aws-scanning-images-pushed-to-management-account-ecr-are-not-scanned) in case you need to scan images pushed to the management account ECR.
* **Deployment cost** This example will create resources that cost money.<br/>Run `terraform destroy` when you don't need them anymore
* For **free subscription** users, beware that organizational examples may not deploy properly due to the [1 cloud-account limitation](https://docs.sysdig.com/en/docs/administration/administration-settings/subscription/#cloud-billing-free-tier). Open an Issue so we can help you here!


<br/>

## Required Permissions

### Provisioning Permissions

Terraform provider credentials/token, requires `Administrative` permissions in order to be able to create the
resources specified in the per-example diagram.

Some components may vary, or may be deployed on different accounts (depending on the example). You can check full resources on each module "Resources" section in their README's. You can also check our source code and suggest changes.

This would be an overall schema of the **created resources**, for the default setup.

- Cloudtrail / SNS / S3 / SQS / KMS
- SSM Parameter for Sysdig API Token Storage
- Sysdig Workload: ECS / AppRunner creation (K8s cluster is pre-required, not created)
  - each compute solution require a role to assume for execution
- CodeBuild for on-demand image scanning
- Sysdig role for [Compliance](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/modules/services/cloud-bench)

### Runtime Permissions

**Threat-Detection specific**

```shell
ssm: GetParameters

sqs: ReceiveMessage
sqs: DeleteMessage

s3: ListBucket
s3: GetObject
```

**Image-Scanning specific**

```shell

# all type scanning
codebuild: StartBuild


# deploy_image_scanning_ecs
ecs:DescribeTaskDefinition

# deploy_image_scanning_ecr
ecr: GetAuthorizationToken
ecr: BatchCheckLayerAvailability
ecr: GetDownloadUrlForLayer
ecr: GetRepositoryPolicy
ecr: DescribeRepositories
ecr: ListImages
ecr: DescribeImages
ecr: BatchGetImage
ecr: GetLifecyclePolicy
ecr: GetLifecyclePolicyPreview
ecr: ListTagsForResource
ecr: DescribeImageScanFindings
  ```
- Other Notes:
  - [Runtime AWS IAM permissions on JSON Statement format](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/resources/sfc-policy.json)
  - only Sysdig workload related permissions are specified above; infrastructure internal resource permissions (such as Cloudtrail permissions to publish on SNS, or SNS-SQS Subscription)
  are not detailed.
  - For a better security, permissions are resource pinned, instead of `*`
  - Check [Organizational Use Case - Role Summary](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/examples/organizational/README.md#role-summary) for more details


<br/>

## Confirm the Services are Working

Check official documentation on [Secure for cloud - AWS, Confirm the Services are working](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/deploy-sysdig-secure-for-cloud-on-aws/#confirm-the-services-are-working)

### General

Generally speaking, a triggered situation (threat or image-scanning) whould be check (from more functional-side to more technical)
- Secure UI > Events / Insights / ...
- Cloud-Connector Logs
- Cloudtrail > Event History

### Forcing Events - Threat Detection

Choose one of the rules contained in an activated Runtime Policies for AWS, such as `Sysdig AWS Activity Logs` policy and execute it in your AWS account.
ex.: 'Delete Bucket Public Access Block' can be easily tested going to an
`S3 bucket > Permissions > Block public access (bucket settings) > edit >
uncheck 'Block all public access'`

Remember that in case you add new rules to the policy you need to give it time to propagate the changes.

In the `cloud-connector` logs you should see similar logs to these
> A public access block for a bucket has been deleted (requesting  user=OrganizationAccountAccessRole, requesting IP=x.x.x.x, AWS  region=eu-central-1, bucket=***

If that's not working as expected, some other questions can be checked
- are events consumed in the sqs queue, or are they pending?
- are events being sent to sns topic?


In `Secure > Events` you should see the event coming through, but beware you may need to activate specific levels such as `Info` depending on the rule you're firing.

Alternativelly, use Terraform example module to trigger **Create IAM Policy that Allows All** event can be found on [examples/trigger-events](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/examples/trigger-events).

### Forcing Events - Image Scanning

:warning: Image scanning is not activated by default.
Ensure you have the [required scanning enablers](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/deploy-sysdig-secure-for-cloud-on-aws/#enabling-image-scanner) in place.

When scanning is activated, should see following lines on the cloud-connector compute componente logs
```
{"component":"ecs-action","message":"starting Cloud Scanning ECS action"}
{"component":"ecr-action","message":"starting Cloud Scanning ECR action"}
```

  - For ECR image scanning, upload any image to an ECR repository of AWS. Can find CLI instructions within the UI of AWS

    It may take some time, but you should see logs detecting the new image in the ECR repository
    ```
    {"component":"ecr-action","message":"processing detection {\"account\":\"***\",\"image\":\"***.dkr.ecr.us-east-1.amazonaws.com/myimage:tag\",\"region\":\"us-east-1\"}. source=aws_cloudtrail"}
    {"component":"ecr-action","message":"starting ECR scanning for ***.dkr.ecr.us-east-1.amazonaws.com/myimage:tag at account ‘***’ region ‘us-east-1’"}
    ```
    and a CodeBuild project being launched successfully

  - For ECS running image scanning, deploy any task in your own cluster, or the one that we create to deploy our workload (ex.`amazon/amazon-ecs-sample` image).

    It may take some time, but you should see logs detecting the new image in the ECS cloud-connector task

    ```
    {"component":"ecs-action","message":"processing detection {\"account\":\"***\",\"region\":\"eu-west-3\",\"taskDefinition\":\"apache:1\"}. source=aws_cloudtrail"}
    {"component":"ecs-action","message":"analyzing task 'apache:1' in region 'eu-west-3'"}
    {"component":"ecs-action","message":"starting ECS scanning for container index 0 in task 'apache:1'"}
    ```
    and a CodeBuild project being launched successfully

<br/><br/>

## Troubleshooting

### Q-Terraform 1.3:  Getting error "Error: Plugin did not respond
A: Seems a bug with some providers
<br/>S: Upgrade to Terraform [1.3.1](https://github.com/hashicorp/terraform/blob/v1.3.1/CHANGELOG.md)

### Q-Debug: Need to modify cloud-connector config (to troubleshoot with `debug` loglevel, modify ingestors for testing, ...)
A: both in ECS and AppRunner workload types, cloud-connector configuration is passed as a base64-encoded string through the env var `CONFIG`
<br/>S: Get current value, decode it, edit the desired (ex.:`logging: debug` value), encode it again, and spin it again with this new definition.
<br/>For information on all the modifyable configuration see [Cloud-Connector Chart](https://charts.sysdig.com/charts/cloud-connector/#configuration-detail) reference

### Q-General: I'm not able to see any data
A: Solution is based on Cloudtrail delivery times
<br/>S: Wait at least 15 minutes [as specified in the official AWS documentation](https://aws.amazon.com/cloudtrail/faqs/#Event_payload.2C_Timeliness.2C_and_Delivery_Frequency)
<br/>For Identity and Access Management, when connected it will be in the [learning mode](https://docs.sysdig.com/en/docs/sysdig-secure/posture/identity-and-access/#understanding-learning-mode-and-disconnected-states)

### Q-CIEM: I'm not able to see Cloud Infrastructure Entitlements Management (CIEM) results
A: Make sure you installed both [cloud-bench](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/modules/services/cloud-bench) and [cloud-connector](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/modules/services/cloud-connector) modules

### Q-Scanning: I'm not able to see any image scanning results
A: Need to check several steps
<br/>S: First, image scanning is not activated by default. Ensure you have the [required scanning enablers](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/deploy-sysdig-secure-for-cloud-on-aws/#enabling-image-scanner) in place.
<br/>Currently, images are scanned on registry/repository push events, and on the supported compute services on deployment. Make sure these events are triggered.
<br/>Dig into secure for cloud compute log (cloud-connector) and check for errors.
<br/>If previous logs are ok, check [spawned scanning service](http://localhost:1313/en/docs/sysdig-secure/sysdig-secure-for-cloud/#summary) logs

### Q-AWS-Scanning: Images pushed to Management Account ECR are not scanned
A: We don’t scan images from the management account ECR because is [not a best pratice](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_best-practices_mgmt-acct.html#best-practices_mgmt-use) to have an ECR in this account.
</br>S: Following Role has to be created in the management account
- Role Name: **OrganizationAccountAccessRole**
- Permissions Policies:
  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CustomPolicy",
            "Effect": "Allow",
            "Action": "ecr:GetAuthorizationToken",
            "Resource": "*"
        }
    ]
  }
  ```
- Trust Relationships:
  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::<ORG_MANAGEMENT_ACCOUNT_ID>:root"
            },
            "Action": "sts:AssumeRole"
        }
    ]
  }
  ```

### Q-General: Getting error "Error: cannot verify credentials" on "sysdig_secure_trusted_cloud_identity" data
A: This happens when Sysdig credentials are not working correctly.
<br/>S: Check sysdig provider block is correctly configured with the `sysdig_secure_url` and `sysdig_secure_api_token` variables
with the correct values. Check [Sysdig SaaS per-region URLs if required](https://docs.sysdig.com/en/docs/administration/saas-regions-and-ip-ranges)

### Q-General-Networking: What's the requirements for the inbound/outbound connection?
A: Refer to [Sysdig SASS Region and IP Ranges Documentation](https://docs.sysdig.com/en/docs/administration/saas-regions-and-ip-ranges/) to get Sysdig SaaS endpoint and allow both outbound (for compute vulnerability report) and inbound (for scheduled compliance checkups)
<br/>ECS type deployment will create following [security-group setup](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/modules/services/cloud-connector-ecs/sec-group.tf)

### Q-AWS: Getting Error "BadRequestException: Cannot create group: group already exists
A: This happens when a previous installation of secure-for-cloud exists. On each account where Sysdig has to create resources, it will create a grouping resource-group using the `name` variable (defaulted to `sfc` on main examples).
<br/>S: Remove previous installation, or if multiple setups are required, use the `name` varible to change the resource-group name.

### Q-AWS: In the ECS compute flavor of secure for cloud, I don't see any logs in the cloud-connector component
A: This may be due to the task not beinb able to start, normally due not not having enough permissions to even fetch the secure apiToken, stored in the AWS SSM service.
<br/>S: Access the task and see if there is any value in the "Stopped Reason" field.

### Q-AWS: Getting error "Error: failed creating ECS Task Definition: ClientException: No Fargate configuration exists for given values.
A: Your ECS task_size values aren't valid for Fargate. Specifically, your mem_limit value is too big for the cpu_limit you specified
<br/>S: Check [supported task cpu and memory values](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)

### Q-AWS: Getting error "404 Invalid parameter: TopicArn" when trying to reuse an existing cloudtrail-sns

```text
│ Error: error creating SNS Topic Subscription: InvalidParameter: Invalid parameter: TopicArn
│ 	status code: 400, request id: 1fe94ceb-9f58-5d39-a4df-169f55d25eba
│
│   with module.cloudvision_aws_single_account.module.cloud_connector.module.cloud_connector_sqs.aws_sns_topic_subscription.this,
│   on ../../../modules/infrastructure/sqs-sns-subscription/main.tf line 6, in resource "aws_sns_topic_subscription" "this":
│    6: resource "aws_sns_topic_subscription" "this" {

```

A: In order to subscribe to a SNS Topic, SQS queue must be in the same region
<br/>S: Change `aws provider` `region` variable to match same region for all resources

### Q-AWS: Getting error "400 availabilityZoneId is invalid" when creating the ECS subnet
```text
│ Error: error creating subnet: InvalidParameterValue: Value (apne1-az3) for parameter availabilityZoneId is invalid. Subnets can currently only be created in the following availability zones: apne1-az1, apne1-az2, apne1-az4.
│ 	status code: 400, request id: 6e32d757-2e61-4220-8106-22ccf814e1fe
│
│   with module.vpc.aws_subnet.public[1],
│   on .terraform/modules/vpc/main.tf line 376, in resource "aws_subnet" "public":
│  376: resource "aws_subnet" "public" {
```

A: For the ECS workload deployment a VPC is being created under the hood. Some AWS zones, such as the 'apne1-az3' in the 'ap-northeast' region does not support NATS, which is activated by default.
<br/>S: Specify the desired VPC region availability zones for the vpc module, using the `ecs_vpc_region_azs` variable to explicit its desired value and workaround the error until AWS gives support for your region.


### Q-AWS: I get 400 api error AuthorizationHeaderMalformed on the Sysdig workload ECS Task

```text
error while receiving the messages: error retrieving from S3 bucket=crit-start-trail: operation error S3: GetObject,
https response error StatusCode: 400, RequestID: ***, HostID: ***,
api error AuthorizationHeaderMalformed: The authorization header is malformed; a non-empty Access Key (AKID) must be provided in the credential."}
```
A: When the S3 bucket, where cloudtrail events are stored, is not in the same account as where the Cloud Connector workload is deployed, it requires the
use of the [`assumeRole` configuration](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/modules/services/cloud-connector/s3-config.tf#L30).
This error happens when the ECS `TaskRole` has no permissions to assume this role
<br/>S: Give permissions to `sts:AssumeRole` to the role used.


### Q-AWS: Getting error 409 `EntityAlreadyExists`

A: Probably you or someone in the same environment you're using, already deployed a resource with the sysdig terraform module and a naming collision is happening.
<br/>S: If you want to maintain several versions, make use of the [`name` input var of the examples](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/single-account-ecs#input_name)

### Q-AWS-Datasources: I'm not able to see my acccount alias in the `Data Sources > Cloud page`
A: There are several causes to this.
<br/>Check that your aws account has an alias set-up. It's not the same as the account name.
```bash
$ aws iam list-account-aliases
```
If all good, test `deploy_benchmark` flag is enabled on your account, hence the trust-relationship is enabled between Sysdig and your cloud infrastructure.
In order to validate the trust-relationship expect no errows on following API.
```shell
$ curl -v https://<SYSDIG_SECURE_ENDPOINT>/api/cloud/v2/accounts/<AWS_ACCOUNT_ID>/validateRole \
--header 'Authorization: Bearer <SYSDIG_SECURE_API_TOKEN>'
```
<br/><br/>

## Upgrading

1. Uninstall previous deployment resources before upgrading
  ```
  $ terraform destroy
  ```

2. Upgrade the full terraform example with
  ```
  $ terraform init -upgrade
  $ terraform plan
  $ terraform apply
  ```

- If the event-source is created throuh SFC, some events may get lost while upgrading with this approach. however, if the cloudtrail is re-used (normal production setup) events will be recovered once the ingestion resumes.

- If required, you can upgrade cloud-connector component by restarting the task (stop task). Because it's not pinned to an specific version, it will download the `latest` one.

<br/>

## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.

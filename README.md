# Sysdig Secure for Cloud in AWS

Terraform module that deploys the [**Sysdig Secure for Cloud** stack in **AWS**](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/deploy-sysdig-secure-for-cloud-on-aws).
<br/>

Provides unified threat-detection, compliance, forensics and analysis through these major components:

* **[CSPM/Compliance](https://docs.sysdig.com/en/docs/sysdig-secure/posture/compliance-unified-/)**: It evaluates periodically your cloud configuration, using Cloud Custodian, against some benchmarks and returns the results and remediation you need to fix. Managed through `cloud-bench` module. <br/>

* **[CIEM](https://docs.sysdig.com/en/docs/sysdig-secure/posture/)**: Permissions and Entitlements management. Requires BOTH modules  `cloud-connector` and `cloud-bench`. <br/>

* **[Cloud Threat Detection](https://docs.sysdig.com/en/docs/sysdig-secure/insights/)**: Tracks abnormal and suspicious activities in your cloud environment based on Falco language. Managed through `cloud-connector` module. <br/>

* **[Cloud Image Scanning](https://docs.sysdig.com/en/docs/sysdig-secure/scanning/)**: Automatically scans all container images pushed to the registry (ECR) and the images that run on the AWS workload (currently ECS). Managed through `cloud-connector`. <br/>

For other Cloud providers check: [GCP](https://github.com/sysdiglabs/terraform-google-secure-for-cloud), [Azure](https://github.com/sysdiglabs/terraform-azurerm-secure-for-cloud)

<br/>

[comment]: <> (## Permissions)

[comment]: <> (Inspect `/module/infrastructure/permissions` subdirectories to understand the several)

[comment]: <> (permissions required.)

[comment]: <> (- `/iam-user` creates an IAM user + adds permissions for required modules &#40;general, cloud-connector, cloud-scanning&#41;<br/><br/>)

[comment]: <> (- `/general` concerns general permissions that apply to both threat-detection and image-scanning features)

[comment]: <> (- `/cloud-connector` for threat-detection features)

[comment]: <> (- `/cloud-scanning` for image-scanning features)

[comment]: <> (TODO review `/module/*/ permissions` vs. the ones in permissions folder)

[comment]: <> (TODO review)

[comment]: <> (- `/org-role-ecs`)

[comment]: <> (- `/org-role-eks`)

## Usage

  - There are several ways to deploy this in you AWS infrastructure, gathered under **[`/examples`](./examples)**
  - Many module,examples and use-cases provide ways to **re-use existing resources (as optionals)** in your infrastructure (cloudtrail, ecs, vpc, k8s cluster,...)
  - Find some real **use-case scenario explanations** under [`/examples-internal/use-cases*`](./examples-internal)
    - [Single Account - Existing Cloudtrail](./examples-internal/use-cases-reuse-resources/single-existing-cloudtrail.md)
    - [Organizational - Existing Cloudtrail, ECS, VPC, Subnet](./examples-internal/use-cases-reuse-resources/org-existing-cloudtrail-ecs-vpc-subnet.md)
    - [Organizational - Existing Cloudtrail withouth SNS, but with S3 configuration, with K8s Cluster and Filtered Cloudtrail Event Account](./examples-internal/use-cases-self-baked/org-s3-k8s-filtered-account.md)

### - Single-Account

Sysdig workload will be deployed in the same account where user's resources will be watched.<br/>
More info in [`./examples/single-account`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/single-account)

![single-account diagram](https://raw.githubusercontent.com/sysdiglabs/terraform-aws-secure-for-cloud/master/examples/single-account/diagram-single.png)


### - Single-Account with a pre-existing Kubernetes Cluster

If you already own a Kubernetes Cluster on AWS, you can use it to deploy Sysdig Secure for Cloud, instead of default ECS cluster.<br/>
More info in [`./examples/single-account-k8s`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/single-account-k8s)

### - Organizational

Using an organizational configuration Cloudtrail.<br/>
More info in [`./examples/organizational`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/organizational)

![organizational diagram](https://raw.githubusercontent.com/sysdiglabs/terraform-aws-secure-for-cloud/master/examples/organizational/diagram-org.png)

### - Self-Baked

If no [examples](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples) fit your use-case, be free to call desired modules directly.

In this use-case we will ONLY deploy cloud-bench, into the target account, calling modules directly.

```terraform
terraform {
  required_providers {
    aws = {}
    sysdig = {
      source  = "sysdiglabs/sysdig"
    }
  }
}

provider "aws" {
  region = "AWS-REGION"
}

provider "sysdig" {
  sysdig_secure_url         = "<SYSDIG_SECURE_URL>"
  sysdig_secure_api_token   = "<SYSDIG_SECURE_API_TOKEN>"
}

module "cloud_bench" {
  source      = "sysdiglabs/secure-for-cloud/aws//modules/services/cloud-bench"
}

```
See [inputs summary](#inputs) or main [module `variables.tf`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/variables.tf) file for more optional configuration.

To run this example you need have your [aws master-account profile configured in CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) and to execute:
```terraform
$ terraform init
$ terraform plan
$ terraform apply
```

### Notice

* **Resource creation inventory** Find all the resources created by Sysdig examples in the resource-group `sysdig-secure-for-cloud` (AWS Resource Group & Tag Editor) <br/><br/>
* **Deployment cost** This example will create resources that cost money.<br/>Run `terraform destroy` when you don't need them anymore

<br/><br/>

## Forcing Events

**Threat Detection**

Terraform example module to trigger **Create IAM Policy that Allows All** event can be found on [examples/trigger-events](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/examples/trigger-events).

In another case, you can do it manually. Choose one of the rules contained in the `AWS Best Practices` policy and execute it in your AWS account.

ex.: 'Delete Bucket Public Access Block' can be easily tested going to an
`S3 bucket > Permissions > Block public access (bucket settings) > edit >
uncheck 'Block all public access'`

Remember that in case you add new rules to the policy you need to give it time to propagate the changes.

In the `cloud-connector` logs you should see similar logs to these
> A public access block for a bucket has been deleted (requesting  user=OrganizationAccountAccessRole, requesting IP=x.x.x.x, AWS  region=eu-central-1, bucket=***

If that's not working as expected, some other questions can be checked
- are events consumed in the sqs queue, or are they pending?
- are events being sent to sns topic?

**Image Scanning**

  - For ECR image scanning, upload any image to an ECR repository of AWS. Can find CLI instructions within the UI of AWS
  - For ECS running image scanning, deploy any task in your own cluster, or the one that we create to deploy our workload (ex.`amazon/amazon-ecs-sample` image).

It may take some time, but you should see logs detecting the new image in the ECS cloud-connector task and a CodeBuild project being launched successfully

<br/><br/>

## Troubleshooting

### Q: Getting error "Error: failed creating ECS Task Definition: ClientException: No Fargate configuration exists for given values.
A: Your ECS task_size values aren't valid for Fargate. Specifically, your mem_limit value is too big for the cpu_limit you specified
S: Check [supported task cpu and memory values](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)

### Q: Getting error "404 Invalid parameter: TopicArn" when trying to reuse an existing cloudtrail-sns

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

### Q: Getting error "400 availabilityZoneId is invalid" when creating the ECS subnet
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


### Q: I'm not able to see Cloud Infrastructure Entitlements Management (CIEM) results
A: Make sure you installed both [cloud-bench](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/modules/services/cloud-bench) and [cloud-connector](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/modules/services/cloud-connector) modules


### Q: I get 400 api error AuthorizationHeaderMalformed on the Sysdig workload ECS Task

```text
error while receiving the messages: error retrieving from S3 bucket=crit-start-trail: operation error S3: GetObject,
https response error StatusCode: 400, RequestID: ***, HostID: ***,
api error AuthorizationHeaderMalformed: The authorization header is malformed; a non-empty Access Key (AKID) must be provided in the credential."}
```
A: When the S3 bucket, where cloudtrail events are stored, is not in the same account as where the Cloud Connector workload is deployed, it requires the
use of the [`assumeRole` configuration](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/modules/services/cloud-connector/s3-config.tf#L30).
This error happens when the ECS `TaskRole` has no permissions to assume this role
<br/>S: Give permissions to `sts:AssumeRole` to the role used.


### Q: How to iterate cloud-connector modification testing

A: Build a custom docker image of cloud-connector `docker build . -t <DOCKER_IMAGE> -f ./build/cloud-connector/Dockerfile` and upload it to any registry (like dockerhub).
Modify the [var.image](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/modules/services/cloud-connector/variables.tf) variable to point to your image and deploy

### Q: How can I iterate ECS modification testing

A: After applying your modifications (vía terraform for example) restart the service
  ```
  $ aws ecs update-service --force-new-deployment --cluster sysdig-secure-for-cloud-ecscluster --service sysdig-secure-for-cloud-cloudconnector --profile <AWS_PROFILE>
  ```
For the AWS_PROFILE, set your `~/.aws/config` to impersonate
  ```
  [profile secure-for-cloud]
  region=eu-central-1
  role_arn=arn:aws:iam::<AWS_MANAGEMENT_ORGANIZATION_ACCOUNT>:role/OrganizationAccountAccessRole
  source_profile=<AWS_MANAGEMENT_ACCOUNT_PROFILE>
  ```

<br/><br/>
## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.

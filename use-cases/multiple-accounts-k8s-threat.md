# Multi-Account - Existing Cloudtrails per account - Existing K8s Cluster

## Use-Case explanation

**Current User Setup**

- [X] multi-account setup
  - [X] per-account cloudtrail, each reporting to their own S3 bucket
- [X] pre-existing resources
    - [?] multiple cloudtrail-S3 buckets synced to a single S3 bucket to which an SQS is attached
    - [?] multiple cloudtrail-S3 buckets reporting to same SQS
    - [X] k8s cluster we want to use to deploy Sysdig for Cloud workload
- [X] permission setup
    - [?] sysdig workload account usage - all required and pre-existing resources exist in the same account
    - [?] sysdig workload account usage - all required resources are in scattered accounts

**Sysdig Secure For Cloud Features**

From the [Secure for cloud AWS available features](https://docs.sysdig.com/en/docs/sysdig-secure/sysdig-secure-for-cloud/aws/#available-features)

- [X] threat-detection
    - [X] account-specific
    - [?] all individual-cloudtrail accounts need to be analysed
- [ ] image-scanning (ECR and ECS)
- [ ] compliance/benchmark
- [ ] CIEM

**Other Requirements**

- [?] pre-existing kubernetes management vía service account (WIP)
  <br/>this has not been tested yet, we rely on an `accessKeyId/secretAccessKey`
<!--
Skip step 4 and remove `aws_access_key_id` and `aws_secret_access_key` parameters from `org_k8s_threat_reuse_cloudtrail` module
-->
- [X] be able to parametrize `nodeSelector` and `tolerations` on the [k8s deployment configuration](https://charts.sysdig.com/charts/cloud-connector/#configuration)

## Solution

For clients that only require thread-detection feature, and do not have an organizational cloudtrail setup, but multiple-accounts,
we can make use of the [cloud-connector `aws-cloudtrail-s3-sns-sqs` ingestor](https://charts.sysdig.com/charts/cloud-connector/#ingestors)

This processes through a single SQS AWS queue the events that come through a single S3 bucket (through an SNS topic) or
multiple S3 buckets (that through several SNS topics, report to a single SQS topic).

## Suggested building-blocks

1. Define different **AWS providers**

   WIP.
    - ?? We need to know the account where Sysdig Secure for cloud workload will be deployed
    - And the accounts where the cloudtrail-S3 bucket(s) will be
<!--
    - Populate  `REGION`. Currently, same region is to be used
    - Because we are going to provision resources on multiple accounts, we're gonna use **two AWS providers**
        - `aws.s3` for s3-sns-sqs resources to be deployed. IAM user-credentials, to be used for k8s must also be in S3 account
        - `aws.sfc` for secure-for-cloud utility resources to be deployed

```terraform
provider "aws" {
  alias = "s3"
  region = "<REGION>"
  ...
}

provider "aws" {
  alias = "sfc"
  region = "<REGION>"
  ...
}
```
-->

2. **Helm provider** definition

Sysdig workload will be deployed through its official **Helm** [cloud-connector chart](https://charts.sysdig.com/charts/cloud-connector/).
<br/>Note: Configure [**Helm** Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs) for **Kubernetes** cluster
<br/>ex:.
```terraform
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

```

3. **Cloudtrail-S3-SNS-SQS**

WIP.

Create an SQS que that will subscribe to one S3-SNS (1) or several S3 buckets SNS topics (2)

We currently provide a module to create first use-case,
[one S3-SNS-SQS](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/modules/infrastructure/cloudtrail_s3-sns-sqs) (1),
but can work on providing a way to automatize the later (2)

<!--
    1. Populate  `CLOUDTRAIL_S3_NAME`
       <br/>ex.:
        ```text
        cloudtrail_s3_name=cloudtrail-logging-237944556329
        ```
    2. Populate `CLOUDTRAIL_S3_FILTER_PREFIX` in order to ingest a specific-account. Otherwise, just remove its assignation
       <br/>ex.:
        ```text
        s3_event_notification_filter_prefix=cloudtrail/AWSLogs/237944556329
        ```

```terraform
module "cloudtrail_s3_sns_sqs" {
  providers = {
    aws = aws.s3
  }
  source  = "sysdiglabs/secure-for-cloud/aws//modules/infrastructure/cloudtrail_s3-sns-sqs"
  cloudtrail_s3_name = "<CLOUDTRAIL_S3_NAME>"
  s3_event_notification_filter_prefix="<CLOUDTRAIL_S3_FILTER_PREFIX>"
}
```
-->

4. Kubernetes Multi-Account **AWS Permissions** to be able to handle S3/SQS operations

Helm Cloud-Connector chart requires specific AWS credentials to be passed by parameter, a new user + access key will
be created within account, to be able to fetch the events in the S3 bucket (1) or several S3 buckets (2)
<br/><br/>
WIP.
<br/><br/>
We currently provide a module to create first use-case,
[`modules/infrastructure/permissions/iam-user`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/modules/infrastructure/permissions/iam-user) (1),
but can work on providing a way to automatize the later (2)

<!--
```terraform
module "multi-account" {
   providers = {
      aws = aws.s3
   }
   source  = "sysdiglabs/secure-for-cloud/aws//modules/infrastructure/permissions/iam-user"
   deploy_image_scanning         = false
   cloudtrail_s3_bucket_arn      = module.cloudtrail_s3_sns_sqs.cloudtrail_s3_arn
   cloudtrail_subscribed_sqs_arn = module.cloudtrail_s3_sns_sqs.cloudtrail_subscribed_sqs_arn
}
```
-->

5. **Sysdig workload deployment on K8s**

   * Populate  `sysdig_secure_url`, `SYSDID_SECURE_API_TOKEN` and `REGION`
   * WIP. enable terraform module to be able to define [`nodeSelector` and `tolerations` parameters of the cloud-connector helm chart](https://charts.sysdig.com/charts/cloud-connector/#configuration)

```terraform
resource "helm_release" "cloud_connector" {

  provider = helm

  name = "cloud-connector"

  repository = "https://charts.sysdig.com"
  chart      = "cloud-connector"

  create_namespace = true
  namespace        = "sysdig"

  set {
    name  = "image.pullPolicy"
    value = "Always"
  }

  set {
    name  = "sysdig.url"
    value =  "<sysdig_secure_url>"
  }

  set_sensitive {
    name  = "sysdig.secureAPIToken"
    value = "<SYSDIG_SECURE_API_TOKEN>"
  }

  set_sensitive {
    name  = "aws.accessKeyId"
    value = "<AWS_ACCESS_KEY>"
  }

  set_sensitive {
    name  = "aws.secretAccessKey"
    value = "<AWS_SECRET_ACCESS_KEY>"
  }

  set {
    name  = "aws.region"
    value = "<REGION>"
  }

  set {
    name  = "nodeSelector.<NODE_SELECTOR_LABEL>"
    value = "<NODE_SELECTOR_LABEL_VALUE>"
  }

  set {
    name  = "tolerations[0].key"
    value = "<TOLERATION_KEY>"
  }

  set {
    name  = "tolerations[0].operator"
    value = "<TOLERATION_OPERATOR>"
  }

  set {
    name  = "tolerations[0].value"
    value = "<TOLERATION_VALUE>"
  }

  set {
    name  = "tolerations[0].effect"
    value = "<TOLERATION_EFFECT>"
  }

  values = [
    <<CONFIG
logging: info
ingestors:
  - aws-cloudtrail-s3-sns-sqs:
      queueURL: CLOUDTRAIL_S3_SNS_SQS_URL
CONFIG
  ]
}

```

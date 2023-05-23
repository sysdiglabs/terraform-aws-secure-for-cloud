# Multi-AWS Accounts with Cloudtrail 

## Overview

**Current User Setup**

- [X] Multi-account setup
  - [X] Per-account cloudtrail, each reporting to their own S3 bucket
- [X] Pre-existing resources
    - [?] Multiple Cloudtrail-S3 buckets synced to a single S3 bucket to which an SQS is attached
    - [?] Multiple Cloudtrail-S3 buckets reporting to same SQS
    - [X] Kubernetes cluster you want to use to deploy Sysdig for Cloud workload
- [X] Permission setup
    - [?] Sysdig workload account usage: all the required and pre-existing resources exist in the same account
    - [?] Sysdig workload account usage: all the required resources are in scattered accounts

**Sysdig Secure For Cloud Features**

From the [available features for Secure for cloud AWS ](https://docs.sysdig.com/en/docs/sysdig-secure/sysdig-secure-for-cloud/aws/#available-features)

- [X] Threat detection
    - [X] Account-specific
    - [?] All individual Cloudtrail accounts need to be analysed
- [ ] Image Scanning (ECR and ECS)
- [ ] Compliance / Benchmark
- [ ] CIEM

**Other Requirements**

- [?] pre-existing kubernetes management vía service account (WIP)
  
  This has not been tested yet; Sysdig rely on an `accessKeyId/secretAccessKey`
  <!--
  Skip step 4 and remove `aws_access_key_id` and `aws_secret_access_key` parameters from `org_k8s_threat_reuse_cloudtrail` module
  -->
  
- [X] Ability to parametrize `nodeSelector` and `tolerations` on the [Kubernetes deployment configuration](https://charts.sysdig.com/charts/cloud-connector/#configuration)

## Solution

If you require only threat detection feature, and do not have an organizational Cloudtrail setup, but has multiple AWS accounts, use the instructions given in [cloud-connector `aws-cloudtrail-s3-sns-sqs` ingestor](https://charts.sysdig.com/charts/cloud-connector/#ingestors).

The ingestor processes a single SQS AWS queue with the events reported from:

-  a single S3 bucket through an SNS topic

- multiple S3 buckets with several SNS topics

## Preparation

1. Define different **AWS providers**.

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

2. Prepare the **Helm provider** definition. 

   1. Use the [cloud-connector chart](https://charts.sysdig.com/charts/cloud-connector/) to deploy the Sysdig workload. 

   2. Configure [**Helm** Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs) for **Kubernetes** cluster:

      For example:

      ```
      provider "helm" {
        kubernetes {
          config_path = "~/.kube/config"
        }
      }
      ```

      

3. Configure the Cloudtrail-S3-SNS-SQS setup

WIP.

Create an SQS queue that will subscribe to:

-  Single S3-SNS setup

  For more information, see the [one S3-SNS-SQS](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/modules/infrastructure/cloudtrail_s3-sns-sqs) module. 

- Multiple S3 buckets with SNS topics 

  We are working to provide a method to automatize this scenario.

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

4. Configure the Kubernetes multi-Account **AWS Permissions** to be able to handle S3/SQS operations:

The  [cloud-connector chart](https://charts.sysdig.com/charts/cloud-connector/)  requires specific AWS credentials to be passed by parameter, for which a new user and an access key will be created within the account. This credential will be used to fetch the events from a single or multiple e S3 buckets. Sysdig currently provide  [`modules/infrastructure/permissions/iam-user`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/modules/infrastructure/permissions/iam-user) to retrieve events from a single S3 bucket.

WIP.

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

5. Deploy the Sysdig workload on Kubernetes:

   * Populate  `sysdig_secure_url`, `SYSDID_SECURE_API_TOKEN` and `REGION`
   
   * WIP. Enable terraform module to be able to define [`nodeSelector` and `tolerations` parameters of the cloud-connector helm chart](https://charts.sysdig.com/charts/cloud-connector/#configuration)
   
     ```json
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
   
     

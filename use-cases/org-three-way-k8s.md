# Organizational Setup: Three-Way Accounts and Kubernetes

## Overview

This use case will cover a three-way cross-account setup (typical from AWS ControlTower landing page) with workload on EKS.

This is terraform-based guidelines, but can also check [Manual Organizational Setup - Three-Way Cross-Account ](./manual-org-three-way.md)

- **User Infrastructure Setup**:

This is the scenario we're going to recreate

  1. Management Account / Accounts
    - Either there is an Organizational Cloudtrail reporting to the log archive account
    - Or several accounts reporting to the same log archive account
  2. Log Archive Account
    - Cloudtrail-S3 bucket, with event notification to an SNS > SQS
  3. Workload/Security Member Account
    - Sysdig Secure for cloud deployment
    - Existing K8S Cluster
      - permission setup rely on an `accessKey/secretAccessKey` parameters of the workload, but can setup the
      service-account manually and ignore those two parameters.

- Required **Sysdig Secure For Cloud [Features](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/)**
  - Threat-Detection
  - :warning: Posture; Compliance + Identity Access Management not delivered with this use-case. Can use [manual compliance setup](./manual-compliance.md)
  - :warning: Cloud image scanning is not supported yet


## Suggested building-blocks

1. Define different **AWS providers**
    - Populate  `REGION`. Currently, same region is to be used
    - Because we are going to provision resources on multiple accounts, we're going to use **two AWS providers**
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
   [Usage of cloudtrail-s3-sns-sqs module](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/modules/infrastructure/cloudtrail_s3-sns-sqs) for cloudtrail's with no sns notification

   1. Populate  `CLOUDTRAIL_S3_NAME`
   <br/>ex.:
       ```text
       cloudtrail_s3_name=cloudtrail-logging-237944556329
       ```
   2. Optionally, populate `CLOUDTRAIL_S3_FILTER_PREFIX` in order to ingest a specific-account. Otherwise, just remove
      its assignation
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
  # s3_event_notification_filter_prefix="<CLOUDTRAIL_S3_FILTER_PREFIX>"
}
```


4. Kubernetes Organizational **User Permissions** to be able to handle S3/SQS operations
<br/>Because Helm Cloud-Connector chart require specific AWS credentials to be passed by parameter, a new user + access key will be created within account. See [`modules/infrastructure/permissions/iam-user`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/modules/infrastructure/permissions/iam-user)

```terraform
module "org_user" {
   providers = {
      aws = aws.s3
   }
   source  = "sysdiglabs/secure-for-cloud/aws//modules/infrastructure/permissions/iam-user"
   deploy_image_scanning         = false
   cloudtrail_s3_bucket_arn      = module.cloudtrail_s3_sns_sqs.cloudtrail_s3_arn
   cloudtrail_subscribed_sqs_arn = module.cloudtrail_s3_sns_sqs.cloudtrail_subscribed_sqs_arn
}
```

5. **Sysdig workload deployment on K8s**

    * Populate  `sysdig_secure_url`, `SYSDID_SECURE_API_TOKEN` and `REGION`

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
    value = module.org_user.sfc_user_access_key_id
  }

  set_sensitive {
    name  = "aws.secretAccessKey"
    value = module.org_user.sfc_user_secret_access_key
  }

  set {
    name  = "aws.region"
    value = "<REGION>"
  }

  values = [
    <<CONFIG
logging: info
ingestors:
  - aws-cloudtrail-s3-sns-sqs:
      queueURL: ${module.cloudtrail_s3_sns_sqs.cloudtrail_subscribed_sqs_url}
CONFIG
  ]
}

```

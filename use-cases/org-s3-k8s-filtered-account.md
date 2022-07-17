# OrganizationalSetup - Existing CloudtrailEventsOnS3 - Existing K8s Cluster - Filtered Account

## Use-Case explanation

**Current User Setup**

- [X] organizational setup
  - [ ] organizational cloudtrail that reports to SNS and persists events in a managed-account stored S3 bucket
  - [X] centralized S3 bucket with cloudtrail-events
  - [ ] member account usage - all required and pre-existing resources exist in the same account
  - [X] member account usage - all required resources are in scattered
- [X] pre-existing resources
  - [ ] k8s cluster we want to use to deploy Sysdig for Cloud workload
  - [ ] organizational cloudtrail, reporting to an SNS topic and delivering events to the S3 bucket
  - [ ] ecs cluster/vpc/subnet we want to use to deploy Sysdig for Cloud workload


**Sysdig Secure For Cloud Features**

- [X] threat-detection
  - [X] account-specific
  - [ ] all accounts of the organization (management account included)
- [ ] image-scanning (WIP?)
- [ ] compliance (WIP?)
- [ ] CIEM (WIP?)

**Other Requirements**

- [X] pre-existing kubernetes management vía service account (WIP)
<br/>this has not been tested yet, we rely on an `accessKey` created specifically for Sysdig-For-Cloud.
<!--
Skip step 4 and remove `aws_access_key_id` and `aws_secret_access_key` parameters from `org_k8s_threat_reuse_cloudtrail` module
-->

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

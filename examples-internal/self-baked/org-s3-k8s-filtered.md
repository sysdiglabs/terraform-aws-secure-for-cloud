# ORG-S3-K8S-FILTERED

## Use-Case explanation

**Current User Setup**
- [X] organizational setup
- [ ] organizational cloudtrail
- [X] centralized S3 bucket with cloudtrail-events

**Sysdig Secure For Cloud Requirements**
- [X] account-specific threat-detection
- [ ] account-specific/organizational? image scanning (WIP)
- [ ] account-specific/organizational? benchmark (WIP)
- [X] pre-existing kubernetes management vía service account (WIP)
This has not been tested yet, we rely on an `accessKey` created specifically for Sysdig-For-Cloud.
<!--
Skip step 4 and remove `aws_access_key_id` and `aws_secret_access_key` parameters from `org_k8s_threat_reuse_cloudtrail` module
-->
---

## Overall Solution Summary


## Suggested building-blocks

1. Define two different **AWS providers**
   1. `s3` for s3-sns-sqs resources to be deployed
   2. `s4c` for secure-for-cloud utilitary resources to be deployed

```terraform
provider "aws" {
  alias      = "s3"
  ...
}

provider "aws" {
  alias      = "s4c"
   ...
}

```

2. **Helm provider** definition
```terraform
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

```

3. **Cloudtrail-S3-SNS-SQS**

   1. Populate  `_CLOUDTRAIL_S3_NAME_`
   <br/>ex.:
    ```text
    cloudtrail_s3_name=cloudtrail-logging-237944556329
    ```
   2. Populate `_CLOUDTRAIL_S3_FILTER_PREFIX_` in order to ingest a specific-account. Otherwise just remove its assignation
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
  cloudtrail_s3_name = _CLOUDTRAIL_S3_NAME_
  s3_event_notification_filter_prefix=_CLOUDTRAIL_S3_FILTER_PREFIX_
}
```


4. Kubernetes Organizational **User Permissions** to be able to handle S3/SQS operations
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

    * Populate  `_SYSDIG_SECURE_ENDPOINT_` and `_SYSDID_SECURE_API_TOKEN_`

```terraform
# force some waiting for org_user creation (eventual consistency)
resource "time_sleep" "wait" {
  depends_on      = [module.org_user]
  create_duration = "5s"
}

module "org_k8s_threat_reuse_cloudtrail" {
    providers = {
      aws = aws.sfc
    }
    source  = "sysdiglabs/secure-for-cloud/aws//examples-internal/organizational-k8s-threat-reuse_cloudtrail"
    name   = "${var.name}-orgk8s"

    sysdig_secure_endpoint    = _SYSDIG_SECURE_ENDPOINT_
    sysdig_secure_api_token   = _SYSDID_SECURE_API_TOKEN_
    cloudtrail_s3_sns_sqs_url = module.cloudtrail_s3_sns_sqs.cloudtrail_subscribed_sqs_url

    aws_access_key_id     = module.org_user.sfc_user_access_key_id
    aws_secret_access_key = module.org_user.sfc_user_secret_access_key

    depends_on = [module.org_user.sfc_user_arn, time_sleep.wait]
}
```

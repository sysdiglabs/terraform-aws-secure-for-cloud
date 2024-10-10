terraform {
  required_providers {
    sysdig = {
      source = "sysdiglabs/sysdig"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "sysdig" {
  sysdig_secure_api_token = var.sysdig_secure_api_token
  sysdig_secure_url       = var.sysdig_secure_url
}

provider "aws" {
  alias      = "admin"
  profile    = var.org_profile
  access_key = var.org_accessKeyId
  secret_key = var.org_secretAccessKey
  region     = var.region
}

provider "aws" {
  alias      = "cloudnative"
  profile    = var.cloudnative_profile
  access_key = var.cloudnative_accessKeyId
  secret_key = var.cloudnative_secretAccessKey
  region     = var.region
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "cloudtrail_s3_sns_sqs" {
  providers = {
    aws = aws.admin
  }
  source                              = "../../../modules/infrastructure/cloudtrail_s3-sns-sqs"
  cloudtrail_s3_name                  = var.cloudtrail_s3_name
  s3_event_notification_filter_prefix = var.s3_event_notification_filter_prefix
  name                                = "${var.name}-orgk8s"
}


module "org_user" {
  providers = {
    aws = aws.admin
  }
  source                        = "../../../modules/infrastructure/permissions/iam-user"
  deploy_image_scanning         = false
  cloudtrail_s3_bucket_arn      = module.cloudtrail_s3_sns_sqs.cloudtrail_s3_arn
  cloudtrail_subscribed_sqs_arn = module.cloudtrail_s3_sns_sqs.cloudtrail_subscribed_sqs_arn
  name                          = "${var.name}-orgk8s"
}


resource "time_sleep" "wait" {
  depends_on      = [module.org_user]
  create_duration = "5s"
}

# -------------------
# actual use case
# -------------------

module "org_k8s_threat_reuse_cloudtrail" {
  providers = {
    aws = aws.cloudnative
  }
  source = "../../../examples-internal/organizational-k8s-threat-reuse_cloudtrail_s3"
  name   = var.name

  cloudtrail_s3_sns_sqs_url = module.cloudtrail_s3_sns_sqs.cloudtrail_subscribed_sqs_url

  aws_access_key_id     = module.org_user.sfc_user_access_key_id
  aws_secret_access_key = module.org_user.sfc_user_secret_access_key

  depends_on = [module.org_user.sfc_user_arn, time_sleep.wait]
}

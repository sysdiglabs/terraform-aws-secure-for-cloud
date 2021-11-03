
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
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


module "cloudtrail_s3_sns_sqs" {
  providers = {
    aws = aws.admin
  }
  source             = "../../../modules/infrastructure/cloudtrail_s3-sns-sqs"
  cloudtrail_s3_name = var.cloudtrail_s3_name
  region             = var.region
}


module "org_credentials_threat" {
  providers = {
    aws = aws.admin
  }
  source                        = "../../../modules/infrastructure/permissions/single-credentials"
  enable_cloud_scanning         = false
  cloudtrail_s3_bucket_arn      = module.cloudtrail_s3_sns_sqs.cloudtrail_s3_arn
  cloudtrail_subscribed_sqs_arn = module.cloudtrail_s3_sns_sqs.cloudtrail_subscribed_sqs_arn
}

module "org_role" {
  providers = {
    aws = aws.admin
  }
  source = "../../../modules/infrastructure/permissions/eks-org-role"

  user_arn              = module.org_credentials_threat.sfc_user_arn
  cloudtrail_s3_arn     = module.cloudtrail_s3_sns_sqs.cloudtrail_s3_arn
  enable_cloud_scanning = false
}



# -------------------
# actual use case
# -------------------

module "org_k8s_threat_reuse_cloudtrail" {
  providers = {
    aws = aws.cloudnative
  }
  source = "../../../examples/organizational-k8s-threat-reuse_cloudtrail"
  name   = var.name
  region = var.region

  sysdig_secure_api_token   = var.sysdig_secure_api_token
  sysdig_secure_endpoint    = var.sysdig_secure_endpoint
  cloudtrail_s3_sns_sqs_url = module.cloudtrail_s3_sns_sqs.cloudtrail_subscribed_sqs_url

  aws_access_key_id     = module.org_credentials_threat.sfc_user_access_key_id
  aws_secret_access_key = module.org_credentials_threat.sfc_user_secret_access_key

  organization_managed_role_arn = module.org_role.sysdig_secure_for_cloud_role_arn

}

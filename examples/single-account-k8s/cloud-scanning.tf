#-------------------------------------
# requirements
#-------------------------------------
module "cloud_scanning_sqs" {
  count  = var.enable_cloud_scanning ? 1 : 0
  source = "../../modules/infrastructure/sqs-sns-subscription"

  name          = "${var.name}-cloud_scanning"
  sns_topic_arn = module.cloudtrail.sns_topic_arn
  tags          = var.tags
}


module "codebuild" {
  count  = var.enable_cloud_scanning ? 1 : 0
  source = "../../modules/infrastructure/codebuild"

  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name

  tags = var.tags
  # note. this is required to avoid race conditions
  depends_on = [module.ssm]
}

#-------------------------------------
# cloud_scanning
#-------------------------------------
resource "helm_release" "cloud_scanning" {
  count = var.enable_cloud_scanning ? 1 : 0
  name  = "cloud-scanning"

  repository = "https://charts.sysdig.com"
  chart      = "cloud-scanning"

  create_namespace = true
  namespace        = var.name

  set_sensitive {
    name  = "aws.accessKeyId"
    value = module.iam_user.sfc_user_access_key_id
  }

  set_sensitive {
    name  = "aws.secretAccessKey"
    value = module.iam_user.sfc_user_secret_access_key
  }

  set_sensitive {
    name  = "sysdig.secureAPIToken"
    value = var.sysdig_secure_api_token
  }

  set {
    name  = "secureAPITokenSecret"
    value = module.ssm.secure_api_token_secret_name
  }

  set {
    name  = "aws.region"
    value = var.region
  }

  set {
    name  = "sysdig.url"
    value = var.sysdig_secure_endpoint
  }

  set {
    name  = "sqsQueueUrl"
    value = module.cloud_scanning_sqs[0].cloudtrail_sns_subscribed_sqs_url
  }

  set {
    name  = "codeBuildProject"
    value = module.codebuild[0].project_name
  }

  depends_on = [module.iam_user]
}

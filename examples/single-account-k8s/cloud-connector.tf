#-------------------------------------
# requirements
#-------------------------------------
module "cloud_connector_sqs" {
  count  = var.deploy_threat_detection ? 1 : 0
  source = "../../modules/infrastructure/sqs-sns-subscription"

  name          = var.name
  sns_topic_arn = local.cloudtrail_sns_arn
  tags          = var.tags
}

module "codebuild" {
  count  = var.deploy_image_scanning ? 1 : 0
  source = "../../modules/infrastructure/codebuild"

  name                         = var.name
  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name

  tags = var.tags
  # note. this is required to avoid race conditions
  depends_on = [module.ssm]
}

#-------------------------------------
# cloud_connector
#-------------------------------------
resource "helm_release" "cloud_connector" {
  count = var.deploy_threat_detection ? 1 : 0

  name       = "cloud-connector"
  repository = "https://charts.sysdig.com"
  chart      = "cloud-connector"

  create_namespace = true
  namespace        = var.name

  set_sensitive {
    name  = "sysdig.secureAPIToken"
    value = var.sysdig_secure_api_token
  }

  set_sensitive {
    name  = "aws.accessKeyId"
    value = module.iam_user.sfc_user_access_key_id
  }

  set_sensitive {
    name  = "aws.secretAccessKey"
    value = module.iam_user.sfc_user_secret_access_key
  }

  set {
    name  = "aws.region"
    value = data.aws_region.current.name
  }

  set {
    name  = "sysdig.url"
    value = var.sysdig_secure_endpoint
  }

  values = [
    yamlencode({
      ingestors = [
        {
          cloudtrail-sns-sqs = {
            queueURL = module.cloud_connector_sqs[0].cloudtrail_sns_subscribed_sqs_url
          }
        }
      ]
      scanners = var.deploy_image_scanning ? [
        {
          aws-ecr = {
            codeBuildProject         = module.codebuild[0].project_name
            secureAPITokenSecretName = module.ssm.secure_api_token_secret_name
          }

          aws-ecs = {
            codeBuildProject         = module.codebuild[0].project_name
            secureAPITokenSecretName = module.ssm.secure_api_token_secret_name
          }
        }
      ] : []
    })
  ]
  depends_on = [module.iam_user]
}

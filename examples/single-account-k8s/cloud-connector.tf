locals {
  deploy_image_scanning   = var.deploy_image_scanning_ecr || var.deploy_image_scanning_ecs
  deploy_scanning_infra   = local.deploy_image_scanning && !var.use_standalone_scanner
  ecr_standalone_scanning = var.deploy_image_scanning_ecr && var.use_standalone_scanner
  ecs_standalone_scanning = var.deploy_image_scanning_ecs && var.use_standalone_scanner
  ecr_scanning_with_infra = var.deploy_image_scanning_ecr && !var.use_standalone_scanner
  ecs_scanning_with_infra = var.deploy_image_scanning_ecs && !var.use_standalone_scanner
}

#-------------------------------------
# requirements
#-------------------------------------
module "cloud_connector_sqs" {
  source = "../../modules/infrastructure/sqs-sns-subscription"

  name          = var.name
  sns_topic_arn = local.cloudtrail_sns_arn
  tags          = var.tags
}

module "codebuild" {
  count  = local.deploy_scanning_infra ? 1 : 0
  source = "../../modules/infrastructure/codebuild"

  name                         = var.name
  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name

  tags       = var.tags
  # note. this is required to avoid race conditions
  depends_on = [module.ssm]
}

#-------------------------------------
# cloud_connector
#-------------------------------------
resource "helm_release" "cloud_connector" {
  name       = "cloud-connector"
  repository = "https://charts.sysdig.com"
  chart      = "cloud-connector"

  create_namespace = true
  namespace        = var.name

  set {
    name  = "sysdig.url"
    value = data.sysdig_secure_connection.current.secure_url
  }

  set_sensitive {
    name  = "sysdig.secureAPIToken"
    value = data.sysdig_secure_connection.current.secure_api_token
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
    name  = "telemetryDeploymentMethod"
    value = "terraform_aws_k8s_single"
  }

  values     = [
    yamlencode({
      logging   = "info"
      rules     = []
      ingestors = [
        {
          cloudtrail-sns-sqs = {
            queueURL = module.cloud_connector_sqs.cloudtrail_sns_subscribed_sqs_url
          }
        }
      ]
      scanners  = [
        merge(
        local.ecr_scanning_with_infra ? {
          aws-ecr = {
            codeBuildProject         = module.codebuild[0].project_name
            secureAPITokenSecretName = module.ssm.secure_api_token_secret_name
          }
        } : {},
        local.ecs_scanning_with_infra ? {
          aws-ecs = {
            codeBuildProject         = module.codebuild[0].project_name
            secureAPITokenSecretName = module.ssm.secure_api_token_secret_name
          }
        } : {},
        local.ecr_standalone_scanning ? {
          aws-ecr-inline = {},
        } : {},
        local.ecs_standalone_scanning ? {
          aws-ecs-inline = {}
        } : {},
        )
      ]
    })
  ]
  depends_on = [module.iam_user]
}

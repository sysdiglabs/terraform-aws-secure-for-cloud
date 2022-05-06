locals {
  default_config = yamlencode(merge({
    logging = "info"
    rules   = []
    ingestors = [
      {
        cloudtrail-sns-sqs = merge(
          {
            queueURL = module.cloud_connector_sqs.cloudtrail_sns_subscribed_sqs_url
          }
        )
      }
    ]
    },
    {
      scanners = local.deploy_image_scanning ? [
        merge(var.deploy_image_scanning_ecr ? {
          aws-ecr = {
            codeBuildProject         = var.build_project_name
            secureAPITokenSecretName = var.secure_api_token_secret_name
          }
          } : {},
          var.deploy_image_scanning_ecs ? {
            aws-ecs = {
              codeBuildProject         = var.build_project_name
              secureAPITokenSecretName = var.secure_api_token_secret_name
            }
        } : {})
      ] : []
    }
  ))
}

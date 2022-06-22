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
        merge(
          local.ecr_scanning_with_infra ? {
            aws-ecr = {
              codeBuildProject         = var.build_project_name
              secureAPITokenSecretName = var.secure_api_token_secret_name
            }
          } : {},
          local.ecs_scanning_with_infra ? {
            aws-ecs = {
              codeBuildProject         = var.build_project_name
              secureAPITokenSecretName = var.secure_api_token_secret_name
            }
        } : {}),
        local.ecs_standalone_scanning ? {
          aws-ecs-inline = {}
        } : {},
        local.ecr_standalone_scanning ? {
          aws-ecr-inline = {},
        } : {}
      ] : []
    }
  ))
}

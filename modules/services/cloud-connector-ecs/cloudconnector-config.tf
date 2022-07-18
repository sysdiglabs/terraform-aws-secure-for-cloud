
locals {
  config = length(var.config) == 0 ? local.default_config : var.config

  default_config = yamlencode(merge({
    logging = "info"
    rules   = []
    ingestors = [
      {
        cloudtrail-sns-sqs = merge(
          {
            queueURL = data.aws_sqs_queue.sqs.url
          },
          var.is_organizational ? {
            assumeRole = var.organizational_config.sysdig_secure_for_cloud_role_arn
          } : {}
        )
      }
    ]
    },
    {
      scanners = local.deploy_image_scanning ? [
        merge(var.deploy_image_scanning_ecr ? {
          aws-ecr = merge({
            codeBuildProject         = var.build_project_name
            secureAPITokenSecretName = var.secure_api_token_secret_name
            },
            var.is_organizational ? {
              masterOrganizationRole       = var.organizational_config.sysdig_secure_for_cloud_role_arn
              organizationalRolePerAccount = var.organizational_config.organizational_role_per_account
          } : {})
          } : {},
          var.deploy_image_scanning_ecs ? {
            aws-ecs = merge({
              codeBuildProject         = var.build_project_name
              secureAPITokenSecretName = var.secure_api_token_secret_name
              },
              var.is_organizational ? {
                masterOrganizationRole       = var.organizational_config.sysdig_secure_for_cloud_role_arn
                organizationalRolePerAccount = var.organizational_config.organizational_role_per_account
            } : {})
        } : {})
      ] : []
    }
  ))
}

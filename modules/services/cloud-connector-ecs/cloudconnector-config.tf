locals {
  default_config = yamlencode(merge({
    logging = "info"
    rules   = []
    ingestors = [
      {
        cloudtrail-sns-sqs = merge(
          {
            queueURL = module.cloud_connector_sqs.cloudtrail_sns_subscribed_sqs_url
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
        merge(
          local.ecs_scanning_with_infra ? {
            aws-ecr = merge({
              codeBuildProject         = var.build_project_name
              secureAPITokenSecretName = var.secure_api_token_secret_name
              },
              var.is_organizational ? {
                masterOrganizationRole       = var.organizational_config.sysdig_secure_for_cloud_role_arn
                organizationalRolePerAccount = var.organizational_config.organizational_role_per_account
            } : {})
          } : {},
          local.ecs_scanning_with_infra ? {
            aws-ecs = merge({
              codeBuildProject         = var.build_project_name
              secureAPITokenSecretName = var.secure_api_token_secret_name
              },
              var.is_organizational ? {
                masterOrganizationRole       = var.organizational_config.sysdig_secure_for_cloud_role_arn
                organizationalRolePerAccount = var.organizational_config.organizational_role_per_account
            } : {})
        } : {}),
        local.ecr_standalone_scanning ? {
          aws-ecr-inline = {},
        } : {},
        local.ecs_standalone_scanning ? {
          aws-ecs-inline = {},
        } : {}
      ] : []
    }
  ))
}

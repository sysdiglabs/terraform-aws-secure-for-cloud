locals {
  default_config = yamlencode(merge({
    logging = "info"
    rules   = []
    ingestors = [
      merge(
        local.deploy_sqs ? {
          cloudtrail-sns-sqs = merge(
            {
              queueURL = module.cloud_connector_sqs[0].cloudtrail_sns_subscribed_sqs_url
            },
            var.is_organizational ? {
              assumeRole = var.organizational_config.sysdig_secure_for_cloud_role_arn
            } : {}
          )
        } : {},
        !local.deploy_sqs && var.existing_cloudtrail_config.cloudtrail_s3_sns_sqs_url != null ? {
          aws-cloudtrail-s3-sns-sqs = merge(
            {
              queueURL = var.existing_cloudtrail_config.cloudtrail_s3_sns_sqs_url
            },
            var.is_organizational ? {
              assumeRole = var.organizational_config.sysdig_secure_for_cloud_role_arn
            } : {}
          )
      } : {})
    ]
    },
    {
      scanners = local.deploy_image_scanning ? [
        merge(var.deploy_beta_image_scanning_ecr ? {
          aws-ecr-inline = merge({},
            var.is_organizational ? {
              masterOrganizationRole       = var.organizational_config.sysdig_secure_for_cloud_role_arn
              organizationalRolePerAccount = var.organizational_config.organizational_role_per_account
            } : {})
            } : {},
          var.deploy_image_scanning_ecr ? {
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

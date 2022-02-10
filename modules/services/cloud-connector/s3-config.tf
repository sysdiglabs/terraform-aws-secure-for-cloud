locals {
  s3_bucket_config_id = aws_s3_bucket.s3_config_bucket.id
}

resource "aws_s3_bucket_object" "config" {
  bucket  = local.s3_bucket_config_id
  key     = "cloud-connector.yaml"
  content = local.default_config
  tags    = var.tags
}

locals {
  default_config = yamlencode(merge({
    logging = "info"
    rules = [
      {
        s3 = {
          bucket = local.s3_bucket_config_id
          path   = "rules"
        }
      }
    ]
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

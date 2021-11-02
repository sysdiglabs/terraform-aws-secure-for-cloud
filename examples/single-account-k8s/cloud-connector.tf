#-------------------------------------
# requirements
#-------------------------------------
module "cloud_connector_sqs" {
  source        = "../../modules/infrastructure/cloudtrail-subscription-sqs"
  name          = "${var.name}-cloud_connector"
  sns_topic_arn = module.cloudtrail.sns_topic_arn
  tags          = var.tags
}


#-------------------------------------
# cloud_connector
#-------------------------------------
resource "helm_release" "cloud_connector" {
  name = "cloud-connector"

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
    value = module.credentials_general.sfc_user_access_key_id
  }

  set_sensitive {
    name  = "aws.secretAccessKey"
    value = module.credentials_general.sfc_user_secret_access_key
  }

  set {
    name  = "aws.region"
    value = var.region
  }

  set {
    name  = "sysdig.url"
    value = var.sysdig_secure_endpoint
  }

  values = [
    <<CONFIG
ingestors:
  - cloudtrail-sns-sqs:
      queueURL: ${module.cloud_connector_sqs.cloudtrail_sns_subscribed_sqs_url}
CONFIG
  ]

  depends_on = [module.credentials_cloud_connector]
}

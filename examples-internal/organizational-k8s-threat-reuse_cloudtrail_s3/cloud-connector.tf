resource "helm_release" "cloud_connector" {

  provider = helm

  name = "cloud-connector"

  repository = "https://charts.sysdig.com"
  chart      = "cloud-connector"

  create_namespace = true
  namespace        = var.name

  set {
    name  = "image.pullPolicy"
    value = "Always"
  }

  set {
    name  = "sysdig.url"
    value = var.sysdig_secure_url
  }

  set_sensitive {
    name  = "sysdig.secureAPIToken"
    value = var.sysdig_secure_api_token
  }

  set_sensitive {
    name  = "aws.accessKeyId"
    value = var.aws_access_key_id
  }

  set_sensitive {
    name  = "aws.secretAccessKey"
    value = var.aws_secret_access_key
  }

  set {
    name  = "aws.region"
    value = data.aws_region.current.name
  }

  values = [
    <<CONFIG
logging: info
ingestors:
  - aws-cloudtrail-s3-sns-sqs:
      queueURL: ${var.cloudtrail_s3_sns_sqs_url}
CONFIG
  ]
}

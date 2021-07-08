data "aws_s3_bucket" "config" {
  bucket = var.config_bucket
}

resource "aws_s3_bucket_object" "config" {
  bucket  = data.aws_s3_bucket.config.id
  key     = "cloud-connector.yaml"
  content = (var.config_content == null && var.config_source == null) ? local.default_config : var.config_content
  //  source  = var.config_source # TODO content or source, not both
}

locals {
  default_config = <<CONFIG
logging: info
rules:
  - secure:
      url: ""
  - s3:
      bucket: ${var.config_bucket}
      path: rules
ingestors:
  - cloudtrail-sns-sqs:
      queueURL: ${aws_sqs_queue.sqs.id}
      interval: 25s
notifiers:
  - cloudwatch:
      logGroup: ${aws_cloudwatch_log_group.log.name}
      logStream: ${aws_cloudwatch_log_stream.stream.name}
  - securityhub:
      productArn: arn:aws:securityhub:${data.aws_region.current.name}::product/sysdig/sysdig-cloud-connector
  - secure:
      url: ""
CONFIG

  task_env_vars = concat([
    {
      name  = "VERIFY_SSL"
      value = tostring(var.verify_ssl)
    },
    {
      name  = "TELEMETRY_DEPLOYMENT_METHOD"
      value = "terraform"
    },
    {
      name  = "FEAT_REGISTER_ACCOUNT_IN_SECURE"
      value = "true"
    },
    {
      name  = "CONFIG_PATH"
      value = "s3://${var.config_bucket}/cloud-connector.yaml"
    }
    ], flatten([for env_key, env_value in var.extra_env_vars : [{
      name  = env_key,
      value = env_value
    }]])
  )
}

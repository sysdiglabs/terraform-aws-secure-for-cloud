
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
  default_config = <<CONFIG
logging: info
rules:
  - s3:
      bucket: ${local.s3_bucket_config_id}
      path: rules
ingestors:
  - cloudtrail-sns-sqs:
      queueURL: ${aws_sqs_queue.sqs.id}
      assumeRole: ${var.services_assume_role_arn}
      interval: 25s
notifiers:
  - cloudwatch:
      logGroup: ${aws_cloudwatch_log_group.log.name}
      logStream: ${aws_cloudwatch_log_stream.stream.name}
CONFIG

  task_env_vars = concat([
    {
      name  = "VERIFY_SSL"
      value = tostring(local.verify_ssl)
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
      value = "s3://${local.s3_bucket_config_id}/cloud-connector.yaml"
    }
    ], flatten([for env_key, env_value in var.extra_env_vars : [{
      name  = env_key,
      value = env_value
    }]])
  )
}

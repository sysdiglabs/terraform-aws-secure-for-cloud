provider "aws" {
  region = var.region
}


#-------------------------------------
# general resources
#-------------------------------------

module "resource_group" {
  source = "../../modules/infrastructure/resource-group"
  name   = var.name
  tags   = var.tags
}

module "ssm" {
  source                  = "../../modules/infrastructure/ssm"
  name                    = var.name
  sysdig_secure_api_token = var.sysdig_secure_api_token
}

module "cloudtrail" {
  source                = "../../modules/infrastructure/cloudtrail"
  name                  = var.name
  is_organizational     = false
  is_multi_region_trail = var.cloudtrail_is_multi_region_trail
  cloudtrail_kms_enable = var.cloudtrail_kms_enable

  tags = var.tags
}

module "cloud_connector_sqs" {
  source        = "../../modules/infrastructure/cloudtrail-subscription-sqs"
  name          = var.name
  sns_topic_arn = module.cloudtrail.sns_topic_arn
  tags          = var.tags
}



#-------------------------------------
# cloud-connector
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
    value = var.aws_access_key_id
  }

  set_sensitive {
    name  = "aws.secretAccessKey"
    value = var.aws_secret_access_key
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
      queueURL: ${module.cloud_connector_sqs.sqs_url}
      interval: 60s
CONFIG
  ]
}

#-------------------------------------
# cloud-scanning
#-------------------------------------

module "codebuild" {
  source                       = "../../modules/infrastructure/codebuild"
  name                         = var.name
  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name

  tags = var.tags
  # note. this is required to avoid race conditions
  depends_on = [module.ssm]
}

resource "aws_sqs_queue" "sqs_scanning" {
  name = "${var.name}-scanning"
  tags = var.tags
}

resource "aws_sns_topic_subscription" "sns_scanning" {
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sqs_scanning.arn
  topic_arn = module.cloudtrail.sns_topic_arn
}

resource "aws_sqs_queue_policy" "cloudtrail_sns_scanning" {
  queue_url = aws_sqs_queue.sqs_scanning.id
  policy    = data.aws_iam_policy_document.cloudtrail_sns_scanning.json

  # required to avoid  error reading SQS Queue Policy; empty result
  depends_on = [aws_sqs_queue.sqs_scanning]
}

data "aws_iam_policy_document" "cloudtrail_sns_scanning" {
  statement {
    sid    = "Allow CloudTrail to send messages"
    effect = "Allow"
    principals {
      identifiers = ["sns.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "sqs:SendMessage",
      "sqs:SendMessageBatch"
    ]
    resources = [aws_sqs_queue.sqs_scanning.arn]
  }
}

resource "helm_release" "cloud_scanning" {
  name = "cloud-scanning"

  repository = "https://charts.sysdig.com"
  chart      = "cloud-scanning"

  # TODO??
  #
  #
  #  chart = "/home/nestor/Projects/work/sysdig/sysdiglabs/charts/charts/cloud-scanning"

  create_namespace = true
  namespace        = var.name

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
    value = var.region
  }

  set {
    name  = "sysdig.url"
    value = var.sysdig_secure_endpoint
  }

  set {
    name  = "sqsQueueUrl"
    value = aws_sqs_queue.sqs_scanning.url
  }

  set {
    name  = "codeBuildProject"
    value = module.codebuild.project_name
  }
}

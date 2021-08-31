provider "aws" {
  region = var.region
}


#-------------------------------------
# general resources
#-------------------------------------

module "resource_group_master" {
  source = "../../modules/infrastructure/resource-group"
  name   = var.name
  tags   = var.tags
}

module "cloudtrail" {
  source                = "../../modules/infrastructure/cloudtrail"
  name                  = var.name
  is_organizational     = false
  is_multi_region_trail = var.cloudtrail_is_multi_region_trail
  cloudtrail_kms_enable = var.cloudtrail_kms_enable

  tags = var.tags
}

resource "aws_sqs_queue" "sqs" {
  name = var.name
  tags = var.tags
}

resource "aws_sns_topic_subscription" "sns" {
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sqs.arn
  topic_arn = module.cloudtrail.sns_topic_arn
}

resource "aws_sqs_queue_policy" "cloudtrail_sns" {
  queue_url = aws_sqs_queue.sqs.id
  policy    = data.aws_iam_policy_document.cloudtrail_sns.json

  # required to avoid  error reading SQS Queue Policy; empty result
  depends_on = [aws_sqs_queue.sqs]
}

data "aws_iam_policy_document" "cloudtrail_sns" {
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
    resources = [aws_sqs_queue.sqs.arn]
  }
}

#-------------------------------------
# cloud-connector
#-------------------------------------

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "cloud_connector" {
  name       = "cloud-connector"

  repository = "https://charts.sysdig.com"
  chart      = "cloud-connector"

  create_namespace = true
  namespace = var.name

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
      queueURL: ${aws_sqs_queue.sqs.url}
      interval: 60s
CONFIG
  ]
}

#-------------------------------------
# cloud-scanning
#-------------------------------------

#module "codebuild" {
#  source                       = "../../modules/infrastructure/codebuild"
#  name                         = var.name
#  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name
#
#  tags = var.tags
#  # note. this is required to avoid racing conditions
#  depends_on = [module.ssm]
#}
#
#
#module "cloud_scanning" {
#  source = "../../modules/services/cloud-scanning"
#  name   = "${var.name}-cloudscanning"
#
#  sysdig_secure_endpoint       = var.sysdig_secure_endpoint
#  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name
#
#  build_project_arn  = module.codebuild.project_arn
#  build_project_name = module.codebuild.project_name
#
#  sns_topic_arn = module.cloudtrail.sns_topic_arn
#
#  ecs_cluster = module.ecs_fargate_cluster.id
#  vpc_id      = module.ecs_fargate_cluster.vpc_id
#  vpc_subnets = module.ecs_fargate_cluster.vpc_subnets
#
#  tags = var.tags
#  # note. this is required to avoid racing conditions
#  depends_on = [module.cloudtrail, module.ecs_fargate_cluster, module.codebuild, module.ssm]
#}

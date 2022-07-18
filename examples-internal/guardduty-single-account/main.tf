provider "sysdig" {
  sysdig_secure_api_token = var.secure_api_token
}

module "resource_group" {
  source = "../../modules/infrastructure/resource-group"

  name = var.name
  tags = var.tags
}

module "ssm" {
  source                  = "../../modules/infrastructure/ssm"
  name                    = var.name
  sysdig_secure_api_token = data.sysdig_secure_connection.current.secure_api_token
  tags                    = var.tags
}


resource "aws_sqs_queue" "sqs" {
  name_prefix = "sfc"
  tags        = var.tags
}

resource "aws_cloudwatch_event_rule" "guardduty_rule" {
  name_prefix   = "sfc-guardduty"
  description   = "GuardDuty Events"
  event_pattern = <<EOF
{
  "source": ["aws.guardduty"],
  "detail-type": ["GuardDuty Finding"]
}
EOF
}

/*
{
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.this_sqs_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_cloudwatch_event_rule.cloudwatch_event_rule.arn}"
        }
      }
    }
  ]
}
*/

data "aws_iam_policy_document" "guardduty_sqs" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.sqs.arn]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudwatch_event_rule.guardduty_rule.arn]
    }
  }
}

resource "aws_sqs_queue_policy" "guardduty" {
  policy    = data.aws_iam_policy_document.guardduty_sqs.json
  queue_url = aws_sqs_queue.sqs.url
}

resource "aws_cloudwatch_event_target" "guardduty_rule" {
  rule = aws_cloudwatch_event_rule.guardduty_rule.name
  arn  = aws_sqs_queue.sqs.arn
}

locals {
  cc_config = yamlencode({
    logging = "info"
    rules = [
      {
        directory = {
          path = "/rules"
        }
      }
    ]
    ingestors = [
      {
        aws-guardduty-eventbridge-sqs = {
          queueURL = aws_sqs_queue.sqs.url
        },
      }
    ]
  })
}


module "cloud_connector" {
  source = "../../modules/services/cloud-connector-ecs"
  name   = "${var.name}-cloudconnector"

  secure_api_token_secret_name = module.ssm.secure_api_token_secret_name

  is_organizational = false

  deploy_image_scanning_ecr = false
  deploy_image_scanning_ecs = false
  build_project_arn         = "na"
  build_project_name        = "na"

  sqs_name = aws_sqs_queue.sqs.name

  config = local.cc_config

  image = "ghcr.io/sysdiglabs/cloud-connector:pr-732"

  ecs_cluster_name            = local.ecs_cluster_name
  ecs_vpc_id                  = local.ecs_vpc_id
  ecs_vpc_subnets_private_ids = local.ecs_vpc_subnets_private_ids
  ecs_task_cpu                = var.ecs_task_cpu
  ecs_task_memory             = var.ecs_task_memory

  tags       = var.tags
  depends_on = [aws_sqs_queue.sqs, module.ssm]
}

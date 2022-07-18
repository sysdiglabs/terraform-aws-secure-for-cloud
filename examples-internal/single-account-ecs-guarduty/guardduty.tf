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

resource "aws_sqs_queue" "sqs" {
  name_prefix = var.name
  tags        = var.tags
}

resource "aws_cloudwatch_event_rule" "guardduty_rule" {
  name_prefix   = "${var.name}-guardduty"
  description   = "GuardDuty Events"
  event_pattern = <<EOF
{
  "source": ["aws.guardduty"],
  "detail-type": ["GuardDuty Finding"]
}
EOF
}

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

resource "aws_sqs_queue" "sqs" {
  name = var.name
  tags = var.tags
}

resource "aws_sns_topic_subscription" "subscription" {
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sqs.arn
  topic_arn = var.sns_topic_arn
}

resource "aws_sqs_queue_policy" "cloudtrail_policy" {
  queue_url = aws_sqs_queue.sqs.url
  policy    = data.aws_iam_policy_document.cloudtrail_policy.json

  # required to avoid  error reading SQS Queue Policy; empty result
  depends_on = [aws_sqs_queue.sqs]
}

data "aws_iam_policy_document" "cloudtrail_policy" {
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

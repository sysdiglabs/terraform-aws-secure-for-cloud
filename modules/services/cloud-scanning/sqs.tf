resource "aws_sqs_queue" "sqs" {
  name = var.name
  tags = var.tags
}

resource "aws_sns_topic_subscription" "sns" {
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sqs.arn
  topic_arn = var.sns_topic_arn
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

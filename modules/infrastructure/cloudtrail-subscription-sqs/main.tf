resource "aws_sqs_queue" "this" {
  name = var.name
  tags = var.tags
}

resource "aws_sns_topic_subscription" "this" {
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.this.arn
  topic_arn = var.sns_topic_arn
}

resource "aws_sqs_queue_policy" "this" {
  queue_url = aws_sqs_queue.this.url
  policy    = data.aws_iam_policy_document.this.json

  # required to avoid  error reading SQS Queue Policy; empty result
  depends_on = [aws_sqs_queue.this]
}

data "aws_iam_policy_document" "this" {
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
    resources = [aws_sqs_queue.this.arn]
  }
}

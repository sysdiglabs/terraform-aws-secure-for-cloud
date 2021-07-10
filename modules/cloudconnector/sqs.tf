resource "aws_sqs_queue" "sqs" {
  tags = var.cloudvision_product_tags
}

resource "aws_sns_topic_subscription" "sns" {
  endpoint  = aws_sqs_queue.sqs.arn
  protocol  = "sqs"
  topic_arn = var.sns_topic_arn
}

resource "aws_sqs_queue_policy" "sqs" {
  policy    = data.aws_iam_policy_document.sqs_queue.json
  queue_url = aws_sqs_queue.sqs.id
}

data "aws_iam_policy_document" "sqs_queue" {
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

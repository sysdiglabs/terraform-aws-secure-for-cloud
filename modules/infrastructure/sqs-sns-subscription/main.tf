resource "aws_sqs_queue" "this" {
  name = var.name
  tags = var.tags
}

resource "aws_sns_topic_subscription" "this" {
  # could do a for_each if required, but 1:1 (sns:sqs) for the moment
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.this.arn
  topic_arn = var.sns_topic_arn
}

resource "aws_sqs_queue_policy" "this" {
  queue_url = aws_sqs_queue.this.url
  policy    = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    sid    = "Allow SNS to send messages to SQS"
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

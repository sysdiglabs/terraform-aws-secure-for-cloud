resource "aws_sqs_queue" "this" {
  # AC_AWS_0366
  # Why: Ensure that your Amazon Simple Queue Service (SQS) queues are protecting the contents of their messages using Server-Side Encryption (SSE).
  #ts:skip=AC_AWS_0366 Doesn't apply as the content of the event is stored on S3 not on the log
  name = var.name
  tags = var.tags
}

resource "aws_sns_topic_subscription" "this" {
  # could do a for_each if required, but 1:1 (sns:sqs) for the moment
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.this.arn
  topic_arn = var.cloudtrail_sns_arn

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
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [var.cloudtrail_sns_arn]
    }
    actions = [
      "sqs:SendMessage"
    ]
    resources = [aws_sqs_queue.this.arn]
  }
}

resource "aws_sqs_queue" "sqs" {
  name = var.name
  tags = var.tags
}

resource "aws_sns_topic_subscription" "sns" {
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sqs.arn
  topic_arn = var.sns_topic_arn

  // wait for vpc before subscription
  depends_on = [aws_vpc_endpoint.sqs]
}

resource "aws_sqs_queue_policy" "cloudtrail_sns" {
  queue_url = aws_sqs_queue.sqs.id
  policy    = data.aws_iam_policy_document.cloudtrail_sns.json

  // required to avoid  error reading SQS Queue Policy; empty result
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


# --------------------------
# vpc
# --------------------------
data "aws_vpc_endpoint_service" "sqs" {
  service      = "sqs"
  service_type = "Interface"
}

resource "aws_vpc_endpoint" "sqs" {
  vpc_id              = var.services_vpc_id
  service_name        = data.aws_vpc_endpoint_service.sqs.service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [var.services_sg_id]
  subnet_ids          = var.services_vpc_private_subnets
  private_dns_enabled = true
  tags                = var.tags
}
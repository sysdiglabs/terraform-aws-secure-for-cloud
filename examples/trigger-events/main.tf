data "aws_iam_policy_document" "flow_log_cloudwatch_assume_role" {
  statement {
    effect = "Allow"
    actions = ["cloudformation:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "policy" {
  name        = "test_policy"
  description = "Trigger event policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = data.aws_iam_policy_document.flow_log_cloudwatch_assume_role.json
}

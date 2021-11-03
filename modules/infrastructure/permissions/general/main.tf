resource "aws_iam_user_policy" "general" {
  name   = var.name
  user   = data.aws_iam_user.this.user_name
  policy = data.aws_iam_policy_document.general.json
}

data "aws_iam_policy_document" "general" {
  statement {
    sid       = "AllowSSMGetParameter"
    effect    = "Allow"
    actions   = ["ssm:GetParameters"]
    resources = [var.secure_api_token_secret_arn]
  }
}

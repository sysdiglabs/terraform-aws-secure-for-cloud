resource "aws_iam_user" "this" {
  name          = var.name
  force_destroy = true
  tags          = var.tags
}

resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name
}


resource "aws_iam_user_policy" "general" {
  name   = var.name
  user   = aws_iam_user.this.name
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

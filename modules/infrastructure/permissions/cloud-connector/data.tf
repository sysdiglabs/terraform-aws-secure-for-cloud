data "aws_region" "this" {}

data "aws_iam_user" "this" {
  user_name = var.sfc_user_name
}

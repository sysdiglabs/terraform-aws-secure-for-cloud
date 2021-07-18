data "aws_caller_identity" "me" {}

resource "aws_s3_bucket" "s3_config_bucket" {
  bucket        = "${var.name}-${data.aws_caller_identity.me.account_id}-config"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
  tags = var.tags
}

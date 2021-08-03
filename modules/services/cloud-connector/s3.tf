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


# --------------------------
# iam, acl
# -------------------------

resource "aws_s3_bucket_public_access_block" "s3_config_bucket" {
  bucket = aws_s3_bucket.s3_config_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

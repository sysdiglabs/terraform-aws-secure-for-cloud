resource "aws_s3_bucket" "s3_config_bucket" {
  bucket        = "${var.name}-config"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
  tags = var.tags
}

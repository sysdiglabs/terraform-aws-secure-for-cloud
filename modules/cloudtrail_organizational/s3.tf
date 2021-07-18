#
# bucket
#

resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "${var.s3_bucket_name}-nonrandom" // FIXME
  acl           = "private"
  force_destroy = true

  lifecycle_rule {
    enabled = true
    expiration {
      days = var.s3_bucket_expiration_days
    }
  }
  tags = var.tags
}



#
# bucket policy ACL + IAM policies
#

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket              = aws_s3_bucket.cloudtrail.id
  block_public_acls   = true
  block_public_policy = true
  depends_on          = [aws_s3_bucket_policy.cloudtrail_s3] # https://github.com/hashicorp/terraform-provider-aws/issues/7628
}



resource "aws_s3_bucket_policy" "cloudtrail_s3" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail_s3.json
}
data "aws_iam_policy_document" "cloudtrail_s3" {

  // begin. required policies as requested in aws_cloudtrail resource documentation
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail.arn]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
    actions = ["s3:PutObject"]
    condition {
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }
    resources = ["${aws_s3_bucket.cloudtrail.arn}/AWSLogs/*"]
  }
  // end


  statement {
    sid    = "AllowS3BucketAndObjectReadAccess"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.cloudvision_account_id}:role/OrganizationAccountAccessRole"
      ]
    }
    resources = [
      aws_s3_bucket.cloudtrail.arn,
      "${aws_s3_bucket.cloudtrail.arn}/AWSLogs/*"
    ]
  }
}

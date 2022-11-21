resource "aws_sns_topic" "cloudtrail" {
  # AC_AWS_0502
  # Why: Encrypt SNS with KMS
  #ts:skip=AC_AWS_0502 Don't encrypt as far as SNS can be provided by customer
  name = var.name
  tags = var.tags
}

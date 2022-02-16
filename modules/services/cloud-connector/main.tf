data "aws_region" "current" {}

locals {
  verify_ssl = var.verify_ssl == "auto" ? length(regexall("https://.*?\\.sysdig(cloud)?.com/?", var.sysdig_secure_url)) == 1 : var.verify_ssl == "true"
}

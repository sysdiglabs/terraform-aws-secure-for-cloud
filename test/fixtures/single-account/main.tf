module "cloudvision_aws_single_account" {
  source = "../../../examples/single-account"
  name   = "${var.name}-single"

  sysdig_secure_api_token = var.sysdig_secure_api_token
  sysdig_secure_endpoint  = var.sysdig_secure_endpoint
  region                  = var.region
}

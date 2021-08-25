module "cloudvision_aws_single_account" {
  source = "../../../examples/single-account"

  sysdig_secure_api_token = var.sysdig_secure_api_token
  sysdig_secure_endpoint  = var.sysdig_secure_endpoint
  name                    = var.name
  region                  = "eu-west-3"
}

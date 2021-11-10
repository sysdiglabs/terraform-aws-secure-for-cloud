provider "aws" {
  region = var.region
}

module "cloudvision_aws_organizational" {
  source = "../../../examples/organizational"
  name   = "${var.name}-org"

  sysdig_secure_api_token                   = var.sysdig_secure_api_token
  sysdig_secure_endpoint                    = var.sysdig_secure_endpoint
  sysdig_secure_for_cloud_member_account_id = var.sysdig_secure_for_cloud_member_account_id
}

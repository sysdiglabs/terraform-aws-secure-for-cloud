module "cloudvision_aws_single_account" {
  source = "../../../examples/organizational"
  name   = var.name
  region = var.region

  sysdig_secure_api_token                   = var.sysdig_secure_api_token
  sysdig_secure_endpoint                    = var.sysdig_secure_endpoint
  sysdig_secure_for_cloud_member_account_id = var.sysdig_secure_for_cloud_member_account_id
}

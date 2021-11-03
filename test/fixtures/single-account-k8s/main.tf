module "cloudvision_aws_single_account_k8s" {
  source = "../../../examples/single-account-k8s"
  name   = "${var.name}-singlek8s"

  sysdig_secure_api_token = var.sysdig_secure_api_token
  sysdig_secure_endpoint  = var.sysdig_secure_endpoint
  region                  = var.region
}

module "cloudvision_aws_single_account" {
  source = "../../../examples/single-account"

  sysdig_secure_api_token = "788b657a-e19c-4c03-a35b-d2c8e2fdf3ee"
  sysdig_secure_endpoint  = "https://secure-staging.sysdig.com"
  name                    = "hayk-cloudvision"
  region                  = "eu-west-3"
}

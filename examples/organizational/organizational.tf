variable "sysdig_secure_api_token" {
  sensitive   = true
  type        = string
  description = "Sysdig Secure API token"
}

variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

variable "aws_organizations_account_email" {
  type        = string
  description = "The email address of the owner to assign to the new member account. This email address must not already be associated with another AWS account"
}


module "cloudvision" {
  source = "../../"

  region                          = "eu-central-1"
  sysdig_secure_api_token         = var.sysdig_secure_api_token
  sysdig_secure_endpoint          = var.sysdig_secure_endpoint
  aws_organizations_account_email = var.aws_organizations_account_email

  // economization
  cloudtrail_organizational_is_multi_region_trail = false
  cloudtrail_organizational_s3_kms_enable         = false
}

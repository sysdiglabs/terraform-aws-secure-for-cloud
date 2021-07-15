variable "sysdig_secure_api_token" {
  sensitive   = true
  type        = string
  description = "Sysdig Secure API token"
}

variable "region" {
  type        = string
  description = "default region for provisioning"
}

variable "aws_organizations_account_email" {
  type        = string
  description = "The email address of the owner to assign to the new member account. This email address must not already be associated with another AWS account"
}

############################
# optionals - with defaults
############################

variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

variable "terraform_connection_profile" {
  type        = string
  default     = "default"
  description = "AWS connection profile to be used on ~/.aws/credentials for organization master account"
}

variable "tags" {
  type        = map(string)
  description = "cloudvision tags"
  default = {
    "product" = "cloudvision"
  }
}

variable "cloudtrail_organizational_s3_kms_enable" {
  type        = bool
  default     = true
  description = "true/false whether s3 should be encrypted"
}

variable "cloudtrail_organizational_is_multi_region_trail" {
  type        = bool
  default     = true
  description = "true/false whether cloudtrail will ingest multiregional events"
}

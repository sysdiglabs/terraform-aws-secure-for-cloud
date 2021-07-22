variable "sysdig_secure_api_token" {
  sensitive   = true
  type        = string
  description = "Sysdig Secure API token"
}


variable "org_cloudvision_account_id" {
  type        = string
  description = "the account_id **within the organization** to be used as cloudvision account"

}

#---------------------------------
# optionals - with defaults
#---------------------------------
variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

variable "aws_connection_profile" {
  type        = string
  default     = "default"
  description = "AWS connection profile to be used on ~/.aws/credentials for organization master account"
}

variable "region" {
  type        = string
  description = "default region for provisioning"
  default     = "eu-central-1"
}

variable "tags" {
  type        = map(string)
  description = "sysdig cloudvision tags"
  default = {
    "product" = "sysdig-cloudvision"
  }
}

variable "org_cloudvision_account_creation_email" {
  type        = string
  default     = ""
  description = "testing-purpose-only, if you want terraform to create the cloudvision account<br/>The email address of the owner to assign to the new member account.<br>This email address must not already be associated with another AWS account"
}

# --------------------
# cloudtrail configuration
# --------------------

variable "cloudtrail_org_is_multi_region_trail" {
  type        = bool
  default     = true
  description = "testing/economization purpose. true/false whether cloudtrail will ingest multiregional events"
}

variable "cloudtrail_org_s3_kms_enable" {
  type        = bool
  default     = true
  description = "testing/economization purpose. true/false whether s3 should be encrypted"
}

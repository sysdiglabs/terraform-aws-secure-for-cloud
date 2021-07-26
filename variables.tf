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


# --------------------
# cloudtrail configuration
# --------------------

variable "cloudtrail_org_is_multi_region_trail" {
  type        = bool
  default     = true
  description = "testing/economization purpose. true/false whether cloudtrail will ingest multiregional events"
}

variable "cloudtrail_org_kms_enable" {
  type        = bool
  default     = true
  description = "testing/economization purpose. true/false whether s3 should be encrypted"
}

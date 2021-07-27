variable "org_cloudvision_account_id" {
  type        = string
  description = "the account_id **within the organization** to be used as cloudvision account"
}

variable "sysdig_secure_api_token" {
  sensitive   = true
  type        = string
  description = "Sysdig Secure API token"
}


#------------------------------
# optionals - with defaults
#------------------------------

variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

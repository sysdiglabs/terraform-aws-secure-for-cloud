variable "sysdig_secure_api_token" {
  sensitive   = true
  type        = string
  description = "Sysdig Secure API token"
}


#------------------------------
# optionals - with defaults
#------------------------------

variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "Default region for resource creation in the account"
}

variable "name" {
  type        = string
  default     = "sysdig-cloudvision"
  description = "Name to be assigned to all child resources"
}

variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

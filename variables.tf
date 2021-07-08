############################
# required
############################

variable "sysdig_secure_api_token" {
  type        = string
  sensitive   = true
  description = "Sysdig Secure API token"
}


############################
# optionals - with default
############################


variable "name" {
  type        = string
  description = "Name for the Cloud Vision deployment"
  default     = "cloudvision"
}

variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

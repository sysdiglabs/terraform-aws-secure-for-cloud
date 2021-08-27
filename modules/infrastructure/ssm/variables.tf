variable "name" {
  type        = string
  description = "Name for the Cloud Vision deployment"
  default     = "sysdig-secure-for-cloud"
}

variable "sysdig_secure_api_token" {
  sensitive   = true
  type        = string
  description = "Sysdig Secure API token"
}

variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}

variable "name" {
  type        = string
  description = "Name for the Cloud Vision deployment"
  default     = "sysdig-cloudvision"
}

variable "sysdig_secure_api_token" {
  sensitive   = true
  type        = string
  description = "Sysdig Secure API token"
}

variable "tags" {
  type        = map(string)
  description = "sysdig cloudvision tags"
  default = {
    "product" = "sysdig-cloudvision"
  }
}

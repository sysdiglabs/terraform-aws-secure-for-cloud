variable "sysdig_secure_api_token" {
  type        = string
  sensitive   = true
  description = "Sysdig secure api token"
}

variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc-tests-kitchen"
}

variable "sysdig_secure_url" {
  type        = string
  description = "Sysdig secure endpoint"
  default     = "https://secure.sysdig.com"
}

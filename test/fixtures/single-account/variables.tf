variable "sysdig_secure_api_token" {
  type        = string
  sensitive   = true
  description = "Sysdig secure api token"
}

variable "name" {
  type        = string
  description = "Name is the prefix used in the resources will be created"
  default     = "sfc-tests-kitchen"
}

variable "region" {
  type        = string
  description = "Region to be deployed"
  default     = "eu-west-3"
}

variable "sysdig_secure_endpoint" {
  type        = string
  description = "Sysdig secure endpoint"
  default     = "https://secure.sysdig.com"
}

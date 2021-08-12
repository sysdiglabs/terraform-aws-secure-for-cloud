variable "sysdig_secure_api_token" {
  sensitive   = true
  type        = string
  description = "Sysdig Secure API token"
}


#------------------------------
# optionals - with defaults
#------------------------------

variable "connector_ecs_task_role_name" {
  type        = string
  default     = "sysdig-cloudvision-connector-ECSTaskRole"
  description = "Name for the ecs task role. This is only required to resolve cyclic dependency with organizational approach"
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

variable "tags" {
  type        = map(string)
  description = "sysdig cloudvision tags"
  default = {
    "product" = "sysdig-cloudvision"
  }
}

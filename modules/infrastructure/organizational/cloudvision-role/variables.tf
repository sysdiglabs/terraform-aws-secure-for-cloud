variable "cloudconnect_ecs_task_role_arn" {
  type        = string
  description = "cloudconnect ecs task role arn"
}


variable "cloudconnect_ecs_task_role_name" {
  type        = string
  description = "cloudconnect ecs task role name"
}


variable "cloudtrail_s3_arn" {
  type        = string
  description = "Cloudtrail S3 bucket ARN"
}

#---------------------------------
# optionals - with defaults
#---------------------------------

# FIXME. workaround due to provider and count conflict on parent module
variable "create" {
  type        = bool
  default     = false
  description = "true/false whether resources are to be created"
}

variable "name" {
  type        = string
  default     = "cloud-connector"
  description = "Name for the Cloud Connector deployment"
}

variable "tags" {
  type        = map(string)
  description = "sysdig cloudvision tags"
  default = {
    "product" = "sysdig-cloudvision"
  }
}

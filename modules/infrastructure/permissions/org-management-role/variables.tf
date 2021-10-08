variable "cloudconnector_ecs_task_role_name" {
  type        = string
  description = "cloudconnector ecs task role name"
}

variable "cloudtrail_s3_arn" {
  type        = string
  description = "Cloudtrail S3 bucket ARN"
}

#---------------------------------
# optionals - with defaults
#---------------------------------

variable "name" {
  type        = string
  default     = "sfc"
  description = "Name for the Cloud Connector deployment"
}

variable "organizational_role_per_account" {
  type        = string
  default     = "OrganizationAccountAccessRole"
  description = "Name of the organizational role deployed by AWS in each account of the organization"
}

variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}

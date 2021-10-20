variable "cloudconnector_ecs_task_role_name" {
  type        = string
  description = "cloudconnector ecs task role name"
}

variable "cloudtrail_s3_arn" {
  type        = string
  description = "Organizational cloudtrail S3 bucket ARN"
}

variable "cloudtrail_sns_arn" {
  type        = string
  description = "Organizational cloudtrail S3 bucket ARN"
}

variable "sysdig_secure_for_cloud_member_account_id" {
  type        = string
  description = "Organizational member account where the secure-for-cloud workload is going to be deployed"
}

#---------------------------------
# optionals - with defaults
#---------------------------------


variable "name" {
  type        = string
  default     = "sfc"
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
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

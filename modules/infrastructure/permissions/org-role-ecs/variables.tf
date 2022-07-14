variable "cloudconnector_ecs_task_role_name" {
  type        = string
  description = "cloudconnector ecs task role name"
}

variable "cloudtrail_config" {
  type = object({
    cloudtrail_s3_arn         = string
    cloudtrail_s3_sns_sqs_arn = optional(string)
  })
  default = {
    cloudtrail_s3_arn         = null
    cloudtrail_s3_sns_sqs_arn = null
  }

  description = <<-EOT
    At least `cloudtrail_s3_arn` is required. `cloudtrail_s3_sns_sqs_arn` optional
  EOT
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
  description = "sysdig secure-for-cloud tags. always include 'product' default tag for resource-group proper functioning"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}

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
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
}

variable "organizational_role_per_account" {
  type        = string
  default     = "OrganizationAccountAccessRole"
  description = "Name of the organizational role deployed by AWS in each account of the organization"
}

variable "tags" {
  type        = map(string)
  description = "customization of tags to be assigned to all resources. <br/>always include 'product' default tag for resource-group proper functioning.<br/>can also make use of the [provider-level `default-tags`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#default_tags)"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}

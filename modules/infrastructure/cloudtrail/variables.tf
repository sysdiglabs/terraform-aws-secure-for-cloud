#---------------------------------
# optionals - with defaults
#---------------------------------

#
# module composition
#

variable "is_organizational" {
  type        = bool
  default     = false
  description = "true/false whether cloudtrail is organizational or not"
}


variable "organizational_config" {
  type = object({
    sysdig_secure_for_cloud_member_account_id = string
    organizational_role_per_account           = string
  })
  default = {
    sysdig_secure_for_cloud_member_account_id = null
    organizational_role_per_account           = null
  }
  description = <<-EOT
    organizational_config. following attributes must be given
    <ul><li>`sysdig_secure_for_cloud_member_account_id` to enable reading permission</li>
    <li>`organizational_role_per_account` to enable SNS topic subscription. by default "OrganizationAccountAccessRole"</li></ul>
  EOT
}

#
# module config
#

variable "s3_bucket_expiration_days" {
  type        = number
  default     = 5
  description = "Number of days that the logs will persist in the bucket"
}

variable "temporary_s3_bucket_public_block" {
  type        = bool
  default     = true
  description = "Create a S3 bucket public access block configuration<br/>This is a temporary variable that will be removed once https://aws.amazon.com/blogs/aws/heads-up-amazon-s3-security-changes-are-coming-in-april-of-2023/ is made effective.<br/>After it, the resource will never be created."
}

variable "cloudtrail_kms_enable" {
  type        = bool
  default     = true
  description = "true/false whether s3 should be encrypted"
}

variable "is_multi_region_trail" {
  type        = bool
  default     = true
  description = "true/false whether cloudtrail will ingest multiregional events"
}


#
# general
#

variable "name" {
  type        = string
  default     = "sfc"
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
}

variable "tags" {
  type        = map(string)
  description = "customization of tags to be assigned to all resources. <br/>always include 'product' default tag for resource-group proper functioning.<br/>can also make use of the [provider-level `default-tags`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#default_tags)"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}

variable "sysdig_secure_api_token" {
  sensitive   = true
  type        = string
  description = "Sysdig Secure API token"
}
#---------------------------------
# optionals - with defaults
#---------------------------------

#
# module composition
#

variable "is_organizational" {
  type        = bool
  default     = false
  description = "whether cloudvision should be deployed in an organizational setup"
}

variable "organizational_config" {

  type = object({
    cloudvision_member_account_id = string
    cloudvision_role_arn          = string
    connector_ecs_task_role_name  = string
  })

  default = {
    cloudvision_member_account_id = null
    cloudvision_role_arn          = null
    connector_ecs_task_role_name  = null
  }

  description = <<-EOT
    organizational_config. following attributes must be given
    <ul><li>`cloudvision_member_account_id` to enable reading permission,</li><li>`cloudvision_role_arn` for cloud-connect assumeRole in order to read cloudtrail s3 events</li><li>and the `connector_ecs_task_role_name` which has been granted trusted-relationship over the cloudvision_role</li></ul>
  EOT
}


#
# cloudtrail configuration
#

variable "cloudtrail_is_multi_region_trail" {
  type        = bool
  default     = true
  description = "testing/economization purpose. true/false whether cloudtrail will ingest multiregional events"
}

variable "cloudtrail_kms_enable" {
  type        = bool
  default     = true
  description = "testing/economization purpose. true/false whether s3 should be encrypted"
}


#
# misc
#

variable "name" {
  type        = string
  description = "Name for the Cloud Vision deployment"
  default     = "sysdig-cloudvision"
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

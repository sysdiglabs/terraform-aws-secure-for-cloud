variable "sysdig_secure_for_cloud_member_account_id" {
  type        = string
  description = "Permission provisioning. Organizational member account where Sysdig Secure for Cloud workload will be deployed."
}

#---------------------------------
# optionals - with defaults
#---------------------------------

#
# cloudtrail configuration
#

variable "cloudtrail_is_multi_region_trail" {
  type        = bool
  default     = true
  description = "true/false whether cloudtrail will ingest multiregional events. testing/economization purpose."
}

variable "cloudtrail_kms_enable" {
  type        = bool
  default     = true
  description = "true/false whether cloudtrail delivered events to S3 should persist encrypted"
}

#
# general
#

variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "Default region for resource creation in both organization master and secure-for-cloud member account"
}


variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc"
}


variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}

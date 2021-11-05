variable "cloudtrail_s3_name" {
  type        = string
  description = "Name of the Cloudtrail S3 bucket"
}

#---------------------------------
# optionals - with defaults
#---------------------------------

variable "s3_event_notification_filter_prefix" {
  type        = string
  default     = ""
  description = "S3 Path filter prefix for event notification"
}

#
# general
#

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

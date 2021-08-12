#---------------------------------
# optionals - with default
#---------------------------------

# FIXME. workaround due to provider and count conflict on parent module
variable "create" {
  type        = bool
  default     = false
  description = "true/false whether resources are to be created"
}

variable "name" {
  type        = string
  description = "Name for the Cloud Vision deployment"
  default     = "sysdig-cloudvision"
}


variable "tags" {
  type        = map(string)
  description = "sysdig cloudvision tags"
  default = {
    "product" = "sysdig-cloudvision"
  }
}

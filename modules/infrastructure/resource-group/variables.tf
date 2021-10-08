#---------------------------------
# optionals - with default
#---------------------------------

variable "name" {
  type        = string
  description = "Name for the Cloud Vision deployment"
  default     = "sfc"
}


variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}

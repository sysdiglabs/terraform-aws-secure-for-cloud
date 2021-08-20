#---------------------------------
# optionals - with defaults
#---------------------------------

variable "name" {
  type        = string
  description = "Deployment name"
  default     = "sysdig-secure-for-cloud"
}

variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}

#---------------------------------
# optionals - with defaults
#---------------------------------

variable "name" {
  type        = string
  description = "Deployment name"
  default     = "sysdig-cloudvision"
}

variable "tags" {
  type        = map(string)
  description = "sysdig cloudvision tags"
  default = {
    "product" = "sysdig-cloudvision"
  }
}

variable "account_id" {
  type        = string
  description = "the account_id in which to provision the cloud-bench IAM role"
}

#---------------------------------
# optionals - with default
#---------------------------------

variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}

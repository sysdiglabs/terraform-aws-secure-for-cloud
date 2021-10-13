variable "account_id" {
  type        = string
  description = "the account_id in which to provision the cloud-bench IAM role"
}

#---------------------------------
# optionals - with default
#---------------------------------

variable "name" {
  type        = string
  description = "The name of the IAM Role that will be created."
  default     = "sfc-cloudbench"
}

variable "regions" {
  type        = list(string)
  description = "List of regions in which to run the benchmark. If empty, the task will contain all aws regions by default."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags"

  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}

#---------------------------------
# optionals - with default
#---------------------------------

variable "name" {
  type = string
  description = "The name of the IAM Role that will be created."
  default = "sfc-cloudbench"
}

variable "is_organizational" {
  type = bool
  default = false
  description = "whether secure-for-cloud should be deployed in an organizational setup"
}

variable "region" {
  type = string
  default = "eu-central-1"
  description = "Default region for resource creation in organization mode"
}

variable "benchmark_regions" {
  type = list(string)
  description = "List of regions in which to run the benchmark. If empty, the task will contain all aws regions by default."
  default = []
}

variable "tags" {
  type = map(string)
  description = "sysdig secure-for-cloud tags"

  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}

variable "provision_in_management_account" {
  type = bool
  default = true
  description = "Whether to deploy the stack in the management account"
}

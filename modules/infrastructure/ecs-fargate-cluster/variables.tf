#---------------------------------
# optionals - with defaults
#---------------------------------

#
# vpc configuration
#
variable "ecs_vpc_region_azs" {
  type        = list(string)
  description = "Explicit list of availability zones for VPC creation. eg: [\"apne1-az1\", \"apne1-az2\"]. If left empty it will be defaulted to two from the default datasource"
  default     = []
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

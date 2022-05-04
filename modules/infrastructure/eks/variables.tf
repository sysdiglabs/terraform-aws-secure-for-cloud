variable "default_vpc_subnets" {
  type        = list(string)
  description = "Default VPC subnets for specified region variable. At least two different AZs are required"
}


#---------------------------------
# optionals - with defaults
#---------------------------------


variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc"
}

#variable "region" {
#  type    = string
#  default = "eu-central-1"
#}

variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags. always include 'product' default tag for resource-group proper functioning"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}

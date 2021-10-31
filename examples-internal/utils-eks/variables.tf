variable "default_vpc_subnets" {
  type        = list(string)
  description = "Default VPC subnets for specified region variable. At least two different AZs are required"
}


#---------------------------------
# optionals - with defaults
#---------------------------------


variable "name" {
  type    = string
  default = "eks-test"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}

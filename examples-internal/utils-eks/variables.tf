variable "default_vpc_subnets" {
  type        = list(string)
  description = "Default VPC subnets for specified region variable"
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

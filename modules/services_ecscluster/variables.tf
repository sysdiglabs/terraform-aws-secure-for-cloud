variable "name" {
  type        = string
  description = "Deployment name"
}

variable "tags" {
  type        = map(string)
  description = "sysdig cloudvision tags"
}


#---------------------------------
# vpc
#---------------------------------

variable "services_vpc_id" {
  type        = string
  description = "services vpc id"
}

variable "services_vpc_private_subnets" {
  type        = list(string)
  description = "services vpc private subnets"
}

variable "services_sg_id" {
  type        = string
  description = "services security group id"
}



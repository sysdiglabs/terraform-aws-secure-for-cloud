data "aws_availability_zones" "zones" {
}

locals {
  ecs_vpc_id = var.ecs_vpc_id == "create" ? module.vpc[0].vpc_id : var.ecs_vpc_id
}


# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
module "vpc" {
  count  = var.ecs_vpc_id == "create" ? 1 : 0
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.name}-vpc"
  cidr = "10.0.0.0/16"

  private_subnets = var.ecs_vpc_subnets_private
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  azs = length(var.ecs_vpc_region_azs) > 0 ? var.ecs_vpc_region_azs : [data.aws_availability_zones.zones.names[0], data.aws_availability_zones.zones.names[1]]

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  enable_vpn_gateway   = false

  tags = var.tags
}

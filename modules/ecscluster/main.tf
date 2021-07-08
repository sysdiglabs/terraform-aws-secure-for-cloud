resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.name
}



data "aws_availability_zones" "zones" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.name}-vpc"
  cidr = "10.0.0.0/16"

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  azs                  = [data.aws_availability_zones.zones.names[0], data.aws_availability_zones.zones.names[1]]
  enable_nat_gateway   = true
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.name
  }
}

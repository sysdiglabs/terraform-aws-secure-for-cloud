resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.name
  tags = var.tags
}

# --------------------------
# vpc
# -------------------------
data "aws_vpc_endpoint_service" "ecs" {
  service      = "ecs"
  service_type = "Interface"
}
resource "aws_vpc_endpoint" "ecs" {
  vpc_id              = var.services_vpc_id
  service_name        = data.aws_vpc_endpoint_service.ecs.service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [var.services_sg_id]
  subnet_ids          = var.services_vpc_private_subnets
  private_dns_enabled = true
  tags                = var.tags
}

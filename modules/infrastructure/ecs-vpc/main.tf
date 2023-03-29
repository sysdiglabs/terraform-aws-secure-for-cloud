resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.name
  tags = var.tags
  #  setting {
  #    name  = "containerInsights"
  #    value = "enabled"
  #  }
}

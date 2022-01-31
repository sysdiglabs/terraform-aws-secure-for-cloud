resource "aws_security_group" "sg" {
  count = local.ecs_sg_deploy ? 1 : 0

  name        = var.name
  description = "CloudConnector workload Security Group"

  vpc_id = local.ecs_vpc_id

  # allow all (protocol -1, from 0, to 0)
  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow all
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

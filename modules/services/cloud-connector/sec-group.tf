resource "aws_security_group" "sg" {
  name        = var.name
  description = "CloudConnector workload Security Group"

  vpc_id = var.ecs_vpc_id

  egress {
    from_port   = 53
    protocol    = "udp"
    to_port     = 53
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 53
    protocol    = "tcp"
    to_port     = 53
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

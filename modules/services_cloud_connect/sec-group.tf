resource "aws_security_group" "sg" {
  vpc_id      = var.vpc
  name        = var.name
  description = "CloudConnector workload Security Group"

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

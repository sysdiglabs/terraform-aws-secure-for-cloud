resource "aws_security_group" "sg" {
  vpc_id      = var.vpc
  name        = var.name
  description = "CloudConnector workload Security Group"
  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
  # TODO, merge both?
  //  tags = {
  //    "Name" : var.name
  //  }
}

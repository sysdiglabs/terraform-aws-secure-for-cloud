resource "aws_security_group" "sg" {
  name        = var.name
  description = "CloudConnector workload Security Group"

  vpc_id = var.ecs_vpc_id

  # Allow outbound DNS traffic over UDP and TCP
  # Used by the ECS task to retrieve secrets from SSM
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

  # Allow outbound HTTPS traffic over TCP
  # Used by Cloud Connector to send events to https://secure.sysdig.com
  egress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

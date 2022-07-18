data "sysdig_secure_connection" "current" {}

data "aws_sqs_queue" "sqs" {
  name = var.sqs_name
}

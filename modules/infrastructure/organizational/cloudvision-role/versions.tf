terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 3.50.0"
      configuration_aliases = [aws.member]
    }
  }
}

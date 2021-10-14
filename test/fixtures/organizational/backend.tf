# Terraform state storage backend
terraform {
  backend "s3" {
    access_key     = var.backend_aws_access_key
    secret_key     = var.backend_aws_secret_access_key
    bucket         = "terraform-cicd-tests"
    key            = "aws-organizational/terraform.tfstate"
    dynamodb_table = "terraform-cicd-test"
    region         = "eu-west-3"
  }
}

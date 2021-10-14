# Terraform state storage backend
terraform {
  backend "s3" {
    profile        = "aws_clodnative"
    bucket         = "terraform-cicd-tests"
    key            = "aws-organizational/terraform.tfstate"
    dynamodb_table = "terraform-cicd-test"
    region         = "eu-west-3"
  }
}

# Terraform state storage backend
terraform {
  backend "s3" {
    bucket         = "terraform-cicd-tests"
    key            = "single-account-terraform.tfstate"
    dynamodb_table = "terraform-cicd-test"
    region         = "eu-west-3"
  }
}

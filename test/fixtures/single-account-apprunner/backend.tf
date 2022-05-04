# Terraform state storage backend
terraform {
  backend "s3" {
    bucket         = "secure-cloud-terraform-tests"
    key            = "aws-single-account-apprunner/terraform.tfstate"
    dynamodb_table = "secure-cloud-terraform-tests"
    region         = "eu-west-3"
  }
}

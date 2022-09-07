# Terraform state storage backend
terraform {
  backend "s3" {
    bucket         = "secure-cloud-terraform-tests" # single examples deploy in qa org/cloudnative  account/s3 bucket
    key            = "aws-single-account-apprunner/terraform.tfstate"
    dynamodb_table = "secure-cloud-terraform-tests"
    region         = "eu-west-3"
  }
}

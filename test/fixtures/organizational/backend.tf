# Terraform state storage backend
terraform {
  backend "s3" {
    bucket         = "secure-cloud-terraform-tests-org" # org examples deploy in org/s3 bucket
    key            = "aws-organizational/terraform.tfstate"
    dynamodb_table = "secure-cloud-terraform-tests"
    region         = "eu-west-3"
  }
}

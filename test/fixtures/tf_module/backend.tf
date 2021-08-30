# Terraform state storage backend
terraform {
  backend "s3" {
    #    bucket = "kitchentest-terraform-casino"
    bucket         = "kitchentest-terraform"
    key            = "terraform.tfstate"
    dynamodb_table = "kitchen-test"
    region         = "eu-west-3"
  }
}

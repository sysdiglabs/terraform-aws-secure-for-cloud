# Terraform state storage backend
terraform {
  backend "s3" {
    bucket         = "secure-cloud-terraform-tests-org" # need to append '-org' to avoid conflict
    key            = "aws-organizational-k8s-reuse_cloudtrail/terraform.tfstate"
    dynamodb_table = "secure-cloud-terraform-tests"
    region         = "eu-west-3"
  }
}

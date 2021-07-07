provider "aws" {
}

module "cloudtrail_organizational" {
  source = "./modules/organizational/cloudtrail"

  cloudtrail_name   = "cloudtrail-org-tf"
  s3_bucket_name    = "cloudtrail-org-tf"
}

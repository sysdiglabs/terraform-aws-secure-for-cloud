provider "aws" {
}

module "cloudtrail_organizational" {
  source = "./modules/organizational/cloudtrail"

  name        = "cloudtrail-org-tf"
  bucket_name = "cloudtrail-org-tf"
}

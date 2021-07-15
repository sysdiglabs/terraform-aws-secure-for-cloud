provider "aws" {
  alias   = "master"
  profile = var.terraform_connection_profile
}

#-------------------------------------
# cloudvision required organizational roles
# TODO move to organizational module?
#-------------------------------------

resource "aws_iam_role" "cloudvision_role" {
  //  name = "CloudConnectoCloudtrailS3ReadOnlyAccess"
  name               = "SysdigCloudVisionRole"
  assume_role_policy = data.aws_iam_policy_document.cloud_vision_role_trusted.json
  tags               = var.tags
}
data "aws_iam_policy_document" "cloud_vision_role_trusted" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${aws_organizations_account.cloudvision.id}:role/OrganizationAccountAccessRole"]
    }
    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role_policy" "cloud_vision_role_s3" {
  role   = aws_iam_role.cloudvision_role.id
  policy = data.aws_iam_policy_document.cloud_vision_role_s3.json
}
data "aws_iam_policy_document" "cloud_vision_role_s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]
    resources = [module.cloudtrail_organizational.s3_bucket_arn, "${module.cloudtrail_organizational.s3_bucket_arn}/*"]
  }
}


#-------------------------------------
# cloudvision-account
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account
#-------------------------------------

resource "aws_organizations_account" "cloudvision" {
  provider = aws.master
  name     = "cloudvision"
  email    = var.aws_organizations_account_email
  tags     = var.tags
}

provider "aws" {
  alias  = "cloudvision"
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.cloudvision.id}:role/OrganizationAccountAccessRole"
  }
}

#-------------------------------------
# cloudvision submodules
#-------------------------------------

module "cloudtrail_organizational" {
  source = "./modules/cloudtrail_organizational"
  providers = {
    aws = aws.master
  }

  cloudvision_account_id = aws_organizations_account.cloudvision.id
  is_multi_region_trail  = var.cloudtrail_organizational_is_multi_region_trail
  s3_kms_enable          = var.cloudtrail_organizational_s3_kms_enable
  tags                   = var.tags
}


module "services" {
  source = "./modules/services"
  providers = {
    aws = aws.cloudvision
  }

  services_assume_role_arn = aws_iam_role.cloudvision_role.arn
  sysdig_secure_endpoint   = var.sysdig_secure_endpoint
  sysdig_secure_api_token  = var.sysdig_secure_api_token
  cloudtrail_sns_topic_arn = module.cloudtrail_organizational.sns_topic_arn
  tags                     = var.tags
}

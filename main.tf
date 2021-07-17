provider "aws" {
  alias   = "master"
  profile = var.terraform_connection_profile
  region  = var.region
}

#-------------------------------------
# cloudvision-account
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account
#-------------------------------------
resource "aws_organizations_account" "cloudvision" {
  count    = (var.aws_organization_sysdig_account.create) ? 1 : 0
  provider = aws.master
  name     = "cloudvision"
  email    = var.aws_organization_sysdig_account.param_creation_email
  tags     = var.tags
}

provider "aws" {
  alias  = "cloudvision"
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::${(var.aws_organization_sysdig_account.create) ? aws_organizations_account.cloudvision[0].id : var.aws_organization_sysdig_account.param_use_account_id}:role/OrganizationAccountAccessRole"
  }
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
      identifiers = ["arn:aws:iam::${(var.aws_organization_sysdig_account.create) ? aws_organizations_account.cloudvision[0].id : var.aws_organization_sysdig_account.param_use_account_id}:role/OrganizationAccountAccessRole"]
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
# cloudvision submodules
#-------------------------------------

module "cloudtrail_organizational" {
  source = "./modules/cloudtrail_organizational"
  providers = {
    aws = aws.master
  }

  cloudvision_account_id = (var.aws_organization_sysdig_account.create) ? aws_organizations_account.cloudvision[0].id : var.aws_organization_sysdig_account.param_use_account_id
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

#---------------------------------------------------------------
# organizational account sysdig-cloudvision resource-group
#---------------------------------------------------------------
resource "aws_resourcegroups_group" "sysdig-cloudvision" {
  name = "sysdig-cloudvision"
  tags = var.tags

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "product",
      "Values": ["sysdig-cloudvision"]
    }
  ]
}
JSON
  }
}

#-------------------------------------
# cloudvision-account creation (optional)
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
#-------------------------------------
resource "aws_iam_role" "cloudvision_role" {
  name               = "SysdigCloudVisionRole"
  assume_role_policy = data.aws_iam_policy_document.cloud_vision_role_trusted.json
  tags               = var.tags
}
data "aws_iam_policy_document" "cloud_vision_role_trusted" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      //      identifiers = ["arn:aws:iam::${(var.aws_organization_sysdig_account.create) ? aws_organizations_account.cloudvision[0].id : var.aws_organization_sysdig_account.param_use_account_id}:role/OrganizationAccountAccessRole"]
      identifiers = [
        "arn:aws:iam::${(var.aws_organization_sysdig_account.create) ? aws_organizations_account.cloudvision[0].id : var.aws_organization_sysdig_account.param_use_account_id}:role/OrganizationAccountAccessRole",
        "arn:aws:iam::778486751722:role/sysdig-cloudvision-cloudconnector-ECSTaskRole"
      ]
    }

    // enable use OrganizationalRole as TaskExecution role for ECS Task
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role_policy" "cloudtrail_s3" {
  name   = "AllowCloudtrailS3Policy"
  role   = aws_iam_role.cloudvision_role.id
  policy = data.aws_iam_policy_document.cloudtrail_s3.json
}
data "aws_iam_policy_document" "cloudtrail_s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]
    resources = [module.cloudtrail_organizational.s3_bucket_arn, "${module.cloudtrail_organizational.s3_bucket_arn}/*"]
  }
}


//resource "aws_iam_role_policy" "cloudservices" {
//  name = "AllowCloudServicesPolicy"
//  role   = aws_iam_role.cloudvision_role.id
//  policy = data.aws_iam_policy_document.cloudservices.json
//}
//data "aws_iam_policy_document" "cloudservices" {
//  statement {
//    effect = "Allow"
//    actions = [
//      "securityhub:GetFindings",
//      "securityhub:BatchImportFindings",
//
//      "logs:DescribeLogStreams",
//      "logs:GetLogEvents",
//      "logs:FilterLogEvents",
//      "logs:PutLogEvents",
//
//      "sqs:DeleteMessageBatch",
//      "sqs:DeleteMessage",
//      "sqs:ReceiveMessage",
//      "sns:Subscribe"
//    ]
//    resources = ["*"]
//    // FIXME. break down policy? try to set cloud-connect sqs queue. not seeming to work
////    resources = ["arn:aws:*:*:${(var.aws_organization_sysdig_account.create) ? aws_organizations_account.cloudvision[0].id : var.aws_organization_sysdig_account.param_use_account_id}:*"]
////    resources = ["arn:aws:sqs:*:${(var.aws_organization_sysdig_account.create) ? aws_organizations_account.cloudvision[0].id : var.aws_organization_sysdig_account.param_use_account_id}:*"]
//  }
//}

locals {
  # only deploy org-management-account lvl role if scanning is deployed and we're not overriding S3Role
  # FIXME. main.tf#72  if scanning is activated, using 'cloudtrail_s3_role_arn' won't work, FR: need to provision 2 roles in cloud-connector
  deploy_org_management_sysdig_role = var.deploy_image_scanning_ecs || var.deploy_image_scanning_ecr || var.existing_cloudtrail_config.cloudtrail_s3_sns_sqs_arn == null
}

module "secure_for_cloud_role" {
  count  = local.deploy_org_management_sysdig_role ? 1 : 0
  source = "../../modules/infrastructure/permissions/org-role-ecs"
  providers = {
    aws.member = aws.member
  }
  name = var.name

  cloudtrail_s3_arn                 = local.cloudtrail_s3_arn
  cloudconnector_ecs_task_role_name = aws_iam_role.connector_ecs_task.name
  organizational_role_per_account   = var.organizational_member_default_admin_role

  tags       = var.tags
  depends_on = [aws_iam_role.connector_ecs_task]
}


# -----------------------------------------------------------------
# secure_for_cloud_role <-> ecs_role trust relationship
# note:
# - definition of a ROOT lvl secure_for_cloud_connector_ecs_tas_role to avoid cyclic dependencies
# - duplicated in ../../modules/services/cloud-connector-ecs/permissions.tf
# -----------------------------------------------------------------
resource "aws_iam_role" "connector_ecs_task" {
  provider           = aws.member
  name               = "${var.name}-${var.connector_ecs_task_role_name}"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role.json
  path               = "/"
  tags               = var.tags
}


data "aws_iam_policy_document" "task_assume_role" {
  provider = aws.member
  statement {
    effect = "Allow"
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

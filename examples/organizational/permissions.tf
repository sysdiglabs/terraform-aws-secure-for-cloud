module "secure_for_cloud_role" {
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
# - duplicated in ../../modules/services/cloud-connector/ecs-service-security.tf
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

module "resource_group_cloudvision_member" {
  providers = {
    aws = aws.member
  }
  source = "../../modules/infrastructure/resource-group"
  name   = var.name
  tags   = var.tags
}


module "cloudvision_role" {
  source = "../../modules/infrastructure/organizational/cloudvision-role"
  providers = {
    aws.member = aws.member
  }
  name = var.name

  cloudtrail_s3_arn               = module.cloudvision.cloudtrail_s3_arn
  cloudconnect_ecs_task_role_name = aws_iam_role.task.name

  tags       = var.tags
  depends_on = [aws_iam_role.task]
}


# -----------------------------------------------------------------
<<<<<<< HEAD

=======
>>>>>>> master
# cloudvision_role <-> ecs_role trust relationship
# note:
# - definition of a ROOT lvl cloudvision_connector_ecs_tas_role to avoid cyclic dependencies
# - duplicated in ../../modules/services/cloud-connector/ecs-service-security.tf
# -----------------------------------------------------------------
resource "aws_iam_role" "task" {
  provider           = aws.member
  name               = var.connector_ecs_task_role_name
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

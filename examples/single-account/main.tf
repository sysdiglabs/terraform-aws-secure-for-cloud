provider "aws" {
<<<<<<< HEAD
  profile = "default"
  region  = "eu-central-1"
=======
  region = var.region
>>>>>>> master
}

module "cloudvision" {
  source = "../../"

  providers = {
    aws.cloudvision = aws
  }
  name                    = var.name
  sysdig_secure_endpoint  = var.sysdig_secure_endpoint
  sysdig_secure_api_token = var.sysdig_secure_api_token

<<<<<<< HEAD
  cloudvision_organizational_setup = {
    is_organizational                 = false
    org_cloudvision_member_account_id = null                             #FIXME add experimental optional vartype?
    org_cloudvision_role              = null                             #FIXME add experimental optional vartype?
    connector_ecs_task_role_name      = var.connector_ecs_task_role_name #FIXME add experimental optional vartype?
  }


=======
>>>>>>> master
  #  (optional) testing purpose; economization
  cloudtrail_org_is_multi_region_trail = false
  cloudtrail_org_kms_enable            = false
}

# note; had to split cloud_bench module due to not being able to use dynamics on provider
# https://github.com/hashicorp/terraform/issues/25244

module "cloud_bench_org" {
  count = var.deploy_benchmark && var.deploy_benchmark_organizational ? 1 : 0

  source = "../../modules/services/cloud-bench"

  name              = "${var.name}-cloudbench"
  is_organizational = true
  region            = data.aws_region.current.name

  tags = var.tags
}

module "cloud_bench_single" {
  count = var.deploy_benchmark && !var.deploy_benchmark_organizational ? 1 : 0
  providers = {
    aws = aws.member
  }

  source = "../../modules/services/cloud-bench"

  name              = "${var.name}-cloudbench"
  is_organizational = false
  region            = data.aws_region.current.name

  tags = var.tags
}

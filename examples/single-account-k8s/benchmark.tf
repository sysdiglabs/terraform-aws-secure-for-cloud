module "cloud_bench" {
  source = "../../modules/services/cloud-bench"
  count  = var.deploy_benchmark ? 1 : 0

  name = "${var.name}-cloudbench"
  tags = var.tags
}

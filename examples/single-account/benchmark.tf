provider "sysdig" {
  sysdig_secure_url          = var.sysdig_secure_endpoint
  sysdig_secure_api_token    = var.sysdig_secure_api_token
  sysdig_secure_insecure_tls = length(regexall("https://.*?\\.sysdig(cloud)?.com/?", var.sysdig_secure_endpoint)) == 1 ? false : true
}

module "cloud_bench" {
  source = "../../modules/services/cloud-bench"
  count  = var.deploy_benchmark ? 1 : 0

  name              = "${var.name}-cloudbench"
  benchmark_regions = var.benchmark_regions

  tags = var.tags
}

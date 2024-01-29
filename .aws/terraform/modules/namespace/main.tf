locals {
  repo = var.repo
  environment = var.environment
  branch = var.branch
  namespace = "${local.repo}-${local.environment}-${local.branch}"
  tags = {
    "repo" : local.repo,
    "environment" : local.environment,
    "branch" : local.branch,
  }
}
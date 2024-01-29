locals {
  repo = var.repo
  environment = var.environment
  branch = var.branch
  namespace = "${repo}-${environment}-${branch}"
  tags = {
    "repo" : repo,
    "environment" : environment,
    "branch" : branch,
  }
}
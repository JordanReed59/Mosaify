data "aws_caller_identity" "current" {}

########## Locals ##########
locals {
  account_id = data.aws_caller_identity.current.account_id
}

module "namespace" {
  source = "./modules/namespace"
  repo = var.repo
  environment = var.environment
  branch = var.branch
}
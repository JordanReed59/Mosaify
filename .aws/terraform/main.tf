module "namespace" {
  source = "./modules/namespace"
  repo = var.repo
  environment = var.environment
  branch = var.branch
}

resource "aws_secretsmanager_secret" "spotify_secret" {
  name = "${module.namespace.namespace}-SPOTIFY_CLIENT_CREDENTIALS"
  tags = module.namespace.tags
}

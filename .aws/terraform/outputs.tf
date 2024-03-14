output "repo" {
  value = module.namespace.repo
}

output "environment" {
  value = module.namespace.environment
}

output "branch" {
  value = module.namespace.branch
}

output "namespace" {
  value = module.namespace.namespace
}

output "tags" {
  value = module.namespace.tags
}

output "s3_bucket_name" {
  value = aws_s3_bucket.static_site_bucket.id
}

output "s3_static_site_url" {
  value = aws_s3_bucket_website_configuration.static_site_bucket.website_endpoint
}

output "api_invoke_url" {
  value = "https://7rek1w0au0.execute-api.us-east-1.amazonaws.com/dev"
}
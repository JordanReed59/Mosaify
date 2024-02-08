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

output "function_uris" {
  value = {
    "auth" = aws_lambda_function.auth_lambda.invoke_arn,
    "url" = aws_lambda_function.url_lambda.invoke_arn,
    "mosaify" = aws_lambda_function.mosaify_lambda.invoke_arn
  }
}

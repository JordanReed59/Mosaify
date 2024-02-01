# add api gateway config
resource "aws_api_gateway_rest_api" "gateway" {
  name        = "${module.namespace.namespace}-api"
  description = "Terraform Serverless API Gateway for Mosaify"
}

resource "aws_api_gateway_resource" "mosaify_method_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.gateway.root_resource_id}"
  path_part   = "auth"
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  resource_id   = aws_api_gateway_resource.mosaify_method_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  resource_id = "${aws_api_gateway_method.post_method.resource_id}"
  http_method = "${aws_api_gateway_method.post_method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:992382358856:function:***-dev-feature-mos-2-auth/invocations"
}

resource "aws_api_gateway_deployment" "deploy_api" {
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  depends_on = [
    aws_api_gateway_resource.mosaify_method_resource,
    aws_api_gateway_integration.post_lambda,
    aws_api_gateway_method.post_method
  ]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.mosaify_method_resource.id,
      aws_api_gateway_integration.post_lambda.id,
      aws_api_gateway_method.post_method.id
    ]))
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deploy_api.id
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  stage_name    = "test"
}
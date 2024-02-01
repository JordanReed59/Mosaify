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
  uri                     = "${aws_lambda_function.mosaify_lambda.invoke_arn}"
}
locals {
  options_lambda_uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${local.account_id}:function:mosaify-dev-feature-mos-2-option/invocations"
  auth_lambda_uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${local.account_id}:function:mosaify-dev-feature-mos-2-auth/invocations"
  options_lambda_name = "mosaify-dev-feature-mos-2-option"
  auth_lambda_name = "mosaify-dev-feature-mos-2-auth"
}

# add api gateway config
resource "aws_api_gateway_rest_api" "gateway" {
  name        = "${module.namespace.namespace}-api"
  description = "Terraform Serverless API Gateway for Mosaify"
}

################ Option resource ################ 
resource "aws_api_gateway_method" "option_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  resource_id   = aws_api_gateway_rest_api.gateway.root_resource_id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# method response
resource "aws_api_gateway_method_response" "options_response" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_rest_api.gateway.root_resource_id
  http_method = aws_api_gateway_method.option_post_method.http_method
  status_code = 200

  response_models = {
    "application/json" = "Empty" # Adjust based on your response content type
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

# integration response
resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_rest_api.gateway.root_resource_id
  http_method = aws_api_gateway_method.option_post_method.http_method
  status_code = aws_api_gateway_method_response.options_response.status_code

  response_templates = {
    "application/json" = ""
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
  }
}


resource "aws_api_gateway_integration" "option_post_lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  resource_id = "${aws_api_gateway_rest_api.gateway.root_resource_id}"
  http_method = "${aws_api_gateway_method.option_post_method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = local.options_lambda_uri
}

resource "aws_lambda_permission" "apigw_option_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = local.options_lambda_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${local.account_id}:${aws_api_gateway_rest_api.gateway.id}/*/${aws_api_gateway_method.option_post_method.http_method}/"
}
################ Option resource ################

################ Auth resource ################
resource "aws_api_gateway_resource" "auth_method_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.gateway.root_resource_id}"
  path_part   = "auth"
}

resource "aws_api_gateway_method" "auth_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  resource_id   = aws_api_gateway_resource.auth_method_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "auth_post_lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  resource_id = "${aws_api_gateway_method.auth_post_method.resource_id}"
  http_method = "${aws_api_gateway_method.auth_post_method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = local.auth_lambda_uri
}

resource "aws_lambda_permission" "apigw_auth_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = local.auth_lambda_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${local.account_id}:${aws_api_gateway_rest_api.gateway.id}/*/${aws_api_gateway_method.auth_post_method.http_method}${aws_api_gateway_resource.auth_method_resource.path}"
}
################ Auth resource ################

################ URL resource ################
# resource "aws_api_gateway_resource" "mosaify_method_resource" {
#   rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
#   parent_id   = "${aws_api_gateway_rest_api.gateway.root_resource_id}"
#   path_part   = "auth"
# }

# resource "aws_api_gateway_method" "post_method" {
#   rest_api_id   = aws_api_gateway_rest_api.gateway.id
#   resource_id   = aws_api_gateway_resource.mosaify_method_resource.id
#   http_method   = "POST"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "post_lambda" {
#   rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
#   resource_id = "${aws_api_gateway_method.post_method.resource_id}"
#   http_method = "${aws_api_gateway_method.post_method.http_method}"

#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${local.account_id}:function:mosaify-dev-feature-mos-2-url/invocations"
# }

# resource "aws_lambda_permission" "apigw_lambda" {
#   statement_id  = "AllowExecutionFromAPIGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = "mosaify-dev-feature-mos-2-auth"
#   principal     = "apigateway.amazonaws.com"

#   # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
#   source_arn = "arn:aws:execute-api:${var.region}:${local.account_id}:${aws_api_gateway_rest_api.gateway.id}/*/${aws_api_gateway_method.post_method.http_method}${aws_api_gateway_resource.mosaify_method_resource.path}"
# }
################ URL resource ################

################ API Deployment ################
resource "aws_api_gateway_deployment" "deploy_api" {
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  depends_on = [
    aws_api_gateway_resource.auth_method_resource,
    aws_api_gateway_method.auth_post_method,
    aws_api_gateway_integration.auth_post_lambda,
    aws_lambda_permission.apigw_auth_lambda,
    aws_api_gateway_method.option_post_method,
    aws_api_gateway_integration.option_post_lambda,
    aws_api_gateway_method_response.options_response,
    aws_api_gateway_integration_response.options_integration_response,
    aws_lambda_permission.apigw_option_lambda
  ]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.auth_method_resource.id,
      aws_api_gateway_method.auth_post_method.id,
      aws_api_gateway_integration.auth_post_lambda.id,
      aws_lambda_permission.apigw_auth_lambda.id,
      aws_api_gateway_method.option_post_method.id,
      aws_api_gateway_integration.option_post_lambda.id,
      aws_api_gateway_method_response.options_response.id,
    aws_api_gateway_integration_response.options_integration_response.id,
      aws_lambda_permission.apigw_option_lambda.id
    ]))
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deploy_api.id
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  stage_name    = "test"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}



resource "aws_api_gateway_rest_api" "this" {
  name        = var.api_name
  description = var.api_description
  tags        = var.tags
}

# Resource for /v1  
resource "aws_api_gateway_resource" "v1" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "v1"
}

# Resource for /v1/health  
resource "aws_api_gateway_resource" "health" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "health"
}

# Method: POST  
resource "aws_api_gateway_method" "get_health_check" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.health.id
  http_method   = "GET"
  authorization = "NONE"
}

# Lambda Integration  
resource "aws_api_gateway_integration" "get_health_integration" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.health.id
  http_method             = aws_api_gateway_method.get_health_check.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.health_check_lambda_arn
}



# Deployment and stage  
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  triggers = {
    redeploy = sha1(jsonencode([
      aws_api_gateway_resource.health.id,
      aws_api_gateway_method.get_health_check.id,
      aws_api_gateway_integration.get_health_integration.id,

    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.get_health_integration
  ]
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stage_name
}


# Lambda permission for API Gateway  
resource "aws_lambda_permission" "apigw_get_health" {
  statement_id  = "AllowAPIGatewayInvokeHealthCheck"
  action        = "lambda:InvokeFunction"
  function_name = var.health_check_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.this.id}/*"
}


resource "aws_apigatewayv2_api" "crud_api" {
  name          = var.name
  protocol_type = "HTTP"
  
  description = var.description

  cors_configuration {
    allow_credentials = false
    allow_headers     = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods     = ["*"]
    allow_origins     = ["*"]
    expose_headers    = []
    max_age          = 0
  }
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id      = aws_apigatewayv2_api.crud_api.id
  name        = var.stage_name
  auto_deploy = true
}

resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.crud_api.id
  name        = "prod"
}

# Integração Lambda Authorizer
resource "aws_apigatewayv2_integration" "lambda_authorizer_integration" {
  api_id             = aws_apigatewayv2_api.crud_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = var.lambda_authorizer_invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

# Integração Lambda Registration
resource "aws_apigatewayv2_integration" "lambda_registration_integration" {
  api_id             = aws_apigatewayv2_api.crud_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = var.lambda_registration_invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

# Rota POST /auth para autenticação
resource "aws_apigatewayv2_route" "auth_route" {
  api_id    = aws_apigatewayv2_api.crud_api.id
  route_key = "POST /auth"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_authorizer_integration.id}"
}

# Rota POST /register para cadastro
resource "aws_apigatewayv2_route" "register_route" {
  api_id    = aws_apigatewayv2_api.crud_api.id
  route_key = "POST /register"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_registration_integration.id}"
}

# Permissões para o API Gateway invocar as funções Lambda
resource "aws_lambda_permission" "api_gateway_lambda_authorizer" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_authorizer_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.crud_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_lambda_registration" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_registration_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.crud_api.execution_arn}/*/*"
}


resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "integration" {
  api_id             = var.api_id
  integration_type   = "AWS_PROXY"
  integration_uri    = var.lambda_function_invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "route" {
  api_id    = var.api_id
  route_key = "GET /api/${var.endpoint_path}"
  target    = "integrations/${aws_apigatewayv2_integration.integration.id}"
}

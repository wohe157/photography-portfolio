resource "aws_apigatewayv2_api" "api" {
  name          = "wh-photography-portfolio-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "prod"
  auto_deploy = true
}

module "list_media_lambda_endpoint" {
  source = "./api_endpoint"

  endpoint_path              = "list-media"
  api_id                     = aws_apigatewayv2_api.api.id
  api_execution_arn          = aws_apigatewayv2_api.api.execution_arn
  lambda_function_name       = module.list_media_lambda.function_name
  lambda_function_invoke_arn = module.list_media_lambda.invoke_arn
}

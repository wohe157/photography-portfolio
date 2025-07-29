output "api_url" {
  description = "API Gateway HTTP endpoint"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

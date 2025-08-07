variable "media_bucket_id" {
  description = "ID of the S3 bucket for media storage"
  type        = string
}

variable "media_bucket_name" {
  description = "Name of the S3 bucket for media storage"
  type        = string
  default     = "wh-photography-portfolio-media"
}

variable "media_bucket_arn" {
  description = "ARN of the S3 bucket for media storage"
  type        = string
}

data "archive_file" "backend_zip" {
  type        = "zip"
  source_file = "${path.root}/../backend/app.py"
  output_path = "${path.root}/../build/backend.zip"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_s3_list_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "lambda-s3-access-policy"
  description = "Allows Lambda to list S3 bucket contents"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:ListBucket"]
        Effect   = "Allow"
        Resource = var.media_bucket_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "backend_function" {
  filename         = data.archive_file.backend_zip.output_path
  function_name    = "wh-photography-portfolio-backend"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "app.lambda_handler"
  source_code_hash = data.archive_file.backend_zip.output_base64sha256
  runtime          = "python3.13"
  timeout          = 10

  environment {
    variables = {
      MEDIA_BUCKET = var.media_bucket_name
    }
  }
}

resource "aws_apigatewayv2_api" "backend_api" {
  name          = "wh-photography-portfolio-backend-api"
  protocol_type = "HTTP"
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backend_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.backend_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "backend_integration" {
  api_id             = aws_apigatewayv2_api.backend_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.backend_function.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "gallery_route" {
  api_id    = aws_apigatewayv2_api.backend_api.id
  route_key = "GET /api/gallery"
  target    = "integrations/${aws_apigatewayv2_integration.backend_integration.id}"
}

resource "aws_apigatewayv2_stage" "backend_stage" {
  api_id      = aws_apigatewayv2_api.backend_api.id
  name        = "prod"
  auto_deploy = true
}

output "api_url" {
  value = aws_apigatewayv2_stage.backend_stage.invoke_url
}

output "api_gateway_domain_name" {
  value = trimsuffix(replace(aws_apigatewayv2_api.backend_api.api_endpoint, "https://", ""), "/")
}

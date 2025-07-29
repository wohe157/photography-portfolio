resource "aws_iam_role" "lambda_exec_role" {
  name = "wh-photography-portfolio-backend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = [
          var.media_bucket_arn,
          "${var.media_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_lambda_function" "gallery" {
  function_name    = "wh-photography-portfolio-gallery"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "app.lambda_handler"
  runtime          = "python3.11"
  filename         = "${path.root}/../build/deployment-package.zip"
  source_code_hash = filebase64sha256("${path.root}/../build/deployment-package.zip")

  environment {
    variables = {
      MEDIA_BUCKET = var.media_bucket_name
    }
  }
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "wh-photography-portfolio-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.gallery.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "gallery" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /api/gallery"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowInvokeFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.gallery.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

variable "endpoint_path" {
  description = "Path of the API endpoint (without the api/ prefix)"
  type        = string
}

variable "api_id" {
  description = "ID of the API Gateway"
  type        = string
}

variable "api_execution_arn" {
  description = "Execution ARN of the API Gateway"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "lambda_function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  type        = string
}

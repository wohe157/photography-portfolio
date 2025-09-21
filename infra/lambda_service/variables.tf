variable "function_name" {
  description = "Name of the Lambda function."
  type        = string
}

variable "archive_file_path" {
  description = "Path of the zip file containing the Lambda function code."
  type        = string
}

variable "handler" {
  description = "The function within your code that Lambda calls to begin execution."
  type        = string
  default     = "main.lambda_handler"
}

variable "runtime" {
  description = "The runtime environment for the Lambda function."
  type        = string
  default     = "python3.13"
}

variable "timeout" {
  description = "The amount of time that Lambda allows a function to run before stopping it."
  type        = number
  default     = 10
}

variable "environment_variables" {
  description = "A map of environment variables to set for the Lambda function."
  type        = map(string)
  default     = {}
}

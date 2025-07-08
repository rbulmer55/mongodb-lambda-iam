variable "api_name" {
  description = "API Gateway name"
  type        = string
}

variable "api_description" {
  description = "API Gateway description"
  type        = string
  default     = ""
}

variable "stage_name" {
  description = "API Gateway deployment stage name"
  type        = string
  default     = "dev"
}

/**
Lambda specific
*/
variable "health_check_lambda_arn" {
  description = "Lambda function invoke ARN"
  type        = string
}

variable "health_check_lambda_name" {
  description = "Lambda function name"
  type        = string
}


variable "tags" {
  description = "Tags passed into the resource"
  type        = map(string)
  default     = {}
}

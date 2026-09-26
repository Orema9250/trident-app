variable "function_name" {
  type        = string
  description = "Lambda Funcion name"
}

variable "dynamodb_table_name" {
  type        = string
  description = "Dynamodb table name"
}

variable "api_gateway_execution_arn" {
  type = string
  description = "api gateway execution arn"
}
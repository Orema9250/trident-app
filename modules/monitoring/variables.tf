variable "region" {
  type        = string
  description = " The region where the resources are created"
}

variable "account_id" {
  type        = string
  description = "The account id"
}

variable "target_group_arn_suffix" {
  type        = string
  description = "Target group arn suffix"
}

variable "lb_arn_suffix" {
  type        = string
  description = "Load Balancer arn suffix"
}

variable "cluster_name" {
  type        = string
  description = "Cluster Name"
}

variable "service_name" {
  type        = string
  description = "Service Name"
}

variable "lambda_function_name" {
  type        = string
  description = "Lambda function name"
}

variable "api_gateway_name" {
  type        = string
  description = "API gateway name"
}

variable "stage_name" {
  type        = string
  description = "Stage name"
}
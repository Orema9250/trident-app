variable "region" {
  type        = string
  description = "The region where resources are created"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "alb_sg_id" {
  type        = string
  description = "Load balancer security group id"
}

variable "account_id" {
  type        = string
  description = "The aws account id"
}

variable "ecr_repository_url" {
  type        = string
  description = "The reposiotry url"
}

variable "image_tag" {
  type        = string
  description = "The image tag from the respository registery"
}

variable "db_secret_arn" {
  type        = string
  description = "The database secret arn "
}

variable "app_subnet_ids" {
  type        = list(string)
  description = "App subnet ids"
}

variable "ecs_target_group_arn" {
  type        = string
  description = "Target group arn"
}

variable "backend_logs_name" {
  type        = string
  description = "backend group logs"
}

variable "db_address" {
  type = string
}

variable "db_port" {
  type = number
}

variable "db_name" {
  type = string
}


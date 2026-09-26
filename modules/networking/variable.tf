variable "region" {
  description = "The regiion the resources is created"
  type        = string
}

variable "cidr_block" {
  description = "The cidr block of the neetwork"
  type        = string
}

variable "availability_zone" {
  description = "The availability zone where subnets are  created"
  type        = list(string)
}

variable "alb_sg_id" {
  type        = string
  description = "The load balancer securiity group id"
}

variable "ecs_sg_id" {
  type        = string
  description = "The ecs security group id"
}
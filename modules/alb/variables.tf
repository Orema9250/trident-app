variable "vpc_id" {
  type        = string
  description = "The VPC id "
}

variable "region" {
  type        = string
  description = "region where this resources is created"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "The public subnet ids"
}

variable "certificate_arn" {
  type        = string
  description = "Certificate arn"
}
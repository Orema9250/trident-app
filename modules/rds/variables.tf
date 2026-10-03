variable "region" {
  type        = string
  description = "Region where all the resources are provisoned"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "ecs_sg_id" {
  type        = string
  description = "The ECS security group id"
}

variable "rds_subnet_ids" {
  type        = list(string)
  description = "The list of database subnet ids"
}

variable "engine_version" {
  description = "The engine version of the instance"
  type        = string
}

variable "allocated_storage" {
  description = "The allocated storage for the instance"
  type        = map(number)
  default = {
    "dev"   = 20
    "stage" = 30
    "prod"  = 40
  }
}

variable "instance_class" {
  description = "The class of the instance"
  type        = map(string)
  default = {
    "dev"   = "db.t3.micro"
    "stage" = "db.t3.micro"
    "prod"  = "db.t3.micro"
  }
}

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "storage_type" {
  description = "Rds storage type"
  type        = map(string)
  default = {
    dev   = "gp3"
    stage = "gp3"
    prod  = "gp3"
  }
}
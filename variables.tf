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


variable "account_id" {
  type        = string
  description = "The aws account id"
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
    "dev"   = "db.t4g.micro"
    "stage" = "db.t4g.micro"
    "prod"  = "db.t4g.micro"
  }
}

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "function_name" {
  type        = string
  description = "lambda_function name"
}

variable "bucket" {
  type        = string
  description = "The name of the bucket which is a global variable"
}

variable "domain_name" {
  type        = string
  description = "The name of the domain used"
}

variable "aliases" {
  type        = list(string)
  description = "The alternative domain names"
}

variable "image_tag" {
  type = string
}

variable "api_domain_name" {
  type        = string
  description = "The api dommain name for backend"
}
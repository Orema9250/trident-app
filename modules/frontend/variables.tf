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

variable "api_domain_name" {
  type        = string
  description = "The api dommain name for backend"

}

variable "alb_dns_name" {
  type        = string
  description = "load balancerr dns name"
}

variable "alb_zone_id" {
  type        = string
  description = "Alb zone id"
}
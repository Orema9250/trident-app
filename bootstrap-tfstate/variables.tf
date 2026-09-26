variable "region" {
  description = "The region where the terraform state is created"
  type        = string
}

variable "tfstate_bucket" {
  description = "The s3 bucket where terraform state is stored"
  type        = string
}
provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket       = "orema-tfstate-bucket-9250"
    key          = "orema/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

module "networking" {
  source            = "./modules/networking"
  region            = var.region
  cidr_block        = var.cidr_block
  availability_zone = var.availability_zone
  alb_sg_id         = module.alb.alb_sg_id
  ecs_sg_id         = module.ecs.ecs_sg_id
}

module "alb" {
  source            = "./modules/alb"
  region            = var.region
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  certificate_arn   = module.frontend.certificate_arn
}

module "ecs" {
  source               = "./modules/ecs"
  region               = var.region
  vpc_id               = module.networking.vpc_id
  alb_sg_id            = module.alb.alb_sg_id
  account_id           = var.account_id
  ecr_repository_url   = module.ecr.ecr_repository_url
  image_tag            = var.image_tag
  db_secret_arn        = module.rds.db_secret_arn
  app_subnet_ids       = module.networking.app_subnet_ids
  ecs_target_group_arn = module.alb.ecs_target_group_arn
  depends_on           = [module.alb]
  backend_logs_name    = module.monitoring.backend_logs_name

  db_address = module.rds.db_address
  db_port    = module.rds.db_port
  db_name    = module.rds.db_name
}

module "rds" {
  source         = "./modules/rds"
  region         = var.region
  vpc_id         = module.networking.vpc_id
  ecs_sg_id      = module.ecs.ecs_sg_id
  rds_subnet_ids = module.networking.rds_subnet_ids
  db_name        = var.db_name
  engine_version = var.engine_version

}

module "ecr" {
  source     = "./modules/ecr"
  region     = var.region
  account_id = var.account_id
}

module "lambda" {
  source                    = "./modules/lambda"
  function_name             = var.function_name
  api_gateway_execution_arn = module.apigateway.api_gateway_execution_arn
  dynamodb_table_name       = module.dynamodb.dynamodb_table_name
}

module "dynamodb" {
  source         = "./modules/dynamodb"
  lambda_role_id = module.lambda.lambda_role_id

}

module "apigateway" {
  source                     = "./modules/apigateway"
  lambda_function_invoke_arn = module.lambda.lambda_function_invoke_arn
}

module "frontend" {
  source          = "./modules/frontend"
  bucket          = var.bucket
  aliases         = var.aliases
  domain_name     = var.domain_name
  api_domain_name = var.api_domain_name
  alb_dns_name    = module.alb.alb_dns_name
  alb_zone_id     = module.alb.alb_zone_id
}

module "monitoring" {
  source                  = "./modules/monitoring"
  region                  = var.region
  account_id              = var.account_id
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  api_gateway_name        = module.apigateway.api_gateway_name
  lambda_function_name    = module.lambda.lambda_function_name
  service_name            = module.ecs.service_name
  cluster_name            = module.ecs.cluster_name
  stage_name              = module.apigateway.stage_name
  lb_arn_suffix           = module.alb.lb_arn_arn_suffix
}












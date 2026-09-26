resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.my_vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.app_rt.id]
}

locals {
  interface_service = [
    "ecr.api",
    "ecr.dkr",
    "logs",
    "ecs-agent",
    "ecs-telemetry",
    "secretsmanager",
    "sns",
    "sqs",
    "rds"
  ]
}

resource "aws_vpc_endpoint" "interface_endpoints" {
  for_each            = toset(local.interface_service)
  vpc_id              = aws_vpc.my_vpc.id
  service_name        = "com.amazonaws.${var.region}.${each.value}"
  subnet_ids          = aws_subnet.app_subnet[*].id
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
}

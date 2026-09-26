resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = var.vpc_id

  ingress {
    to_port         = 5432
    from_port       = 5432
    security_groups = [var.ecs_sg_id]
    protocol        = "tcp"
  }
  egress = []
}

resource "aws_security_group" "ecs_sg" {
  name   = "ecs-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 3000
    to_port         = 3000
    security_groups = [var.alb_sg_id]
    protocol        = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
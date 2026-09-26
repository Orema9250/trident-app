resource "aws_security_group" "endpoint_sg" {
  name   = "endpoint_sg"
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port       = 443
    to_port         = 443
    security_groups = [var.ecs_sg_id]
    protocol        = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "endpoint_sg"
  }
}

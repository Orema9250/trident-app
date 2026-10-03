resource "aws_db_subnet_group" "subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.rds_subnet_ids[*]

  tags = {
    Name = "My-DB-subnet-group"
  }
}


resource "aws_db_instance" "rds_db" {
  allocated_storage           = var.allocated_storage[terraform.workspace]
  storage_type                = var.storage_type[terraform.workspace]
  db_name                     = var.db_name
  engine                      = "postgres"
  engine_version              = var.engine_version
  instance_class              = var.instance_class[terraform.workspace]
  skip_final_snapshot         = true
  manage_master_user_password = true
  username                    = "orema"
  db_subnet_group_name        = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids      = [aws_security_group.rds_sg.id]
  publicly_accessible         = false
}

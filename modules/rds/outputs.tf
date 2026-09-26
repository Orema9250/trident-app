output "db_secret_arn" {
  value = aws_db_instance.rds_db.master_user_secret[0].secret_arn
}

output "db_name" {
  value = aws_db_instance.rds_db.db_name
}


output "db_port" {
  value = aws_db_instance.rds_db.port
}


output "db_address" {
  value = aws_db_instance.rds_db.address
}
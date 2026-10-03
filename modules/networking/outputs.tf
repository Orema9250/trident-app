output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "rds_subnet_ids" {
  value = aws_subnet.database_subnet[*].id

}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "app_subnet_ids" {
  value = aws_subnet.app_subnet[*].id
}
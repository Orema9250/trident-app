resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.app_subnet[0].id
  depends_on    = [aws_internet_gateway.my_igw]
}
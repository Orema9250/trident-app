resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_route_table_association" "public_rta" {
  count          = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_route_table" "app_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "app_rta" {
  subnet_id      = aws_subnet.app_subnet[count.index].id
  route_table_id = aws_route_table.app_rt.id
  count          = 2
}

resource "aws_route_table" "database_rt" {
  vpc_id = aws_vpc.my_vpc.id
}


resource "aws_route_table_association" "database_rta" {
  subnet_id      = aws_subnet.database_subnet[count.index].id
  route_table_id = aws_route_table.database_rt.id
  count          = 2
}


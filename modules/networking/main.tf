resource "aws_vpc" "my_vpc" {
  enable_dns_hostnames = true
  enable_dns_support   = true
  cidr_block           = var.cidr_block

}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  map_public_ip_on_launch = true
  cidr_block              = cidrsubnet(var.cidr_block, 8, count.index + 1)
  availability_zone       = var.availability_zone[count.index]
  count                   = 2
}

resource "aws_subnet" "app_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index + 3)
  count             = 2
  availability_zone = var.availability_zone[count.index]
}

resource "aws_subnet" "database_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index + 5)
  count             = 2
  availability_zone = var.availability_zone[count.index]
}

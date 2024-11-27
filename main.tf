# VPC creation
resource "aws_vpc" "atharva_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "atharva-vpc"
  }
}

# Internet Gateway creation
resource "aws_internet_gateway" "atharva_vpc_igw" {
  vpc_id = aws_vpc.atharva_vpc.id
  tags = {
    Name = "atharva-vpc-igw"
  }
}

# Subnet creation
resource "aws_subnet" "atharva_vpc_public_sub" {
  vpc_id = aws_vpc.atharva_vpc.id
  cidr_block = var.pub_sub_cidr
  map_public_ip_on_launch = "true"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "atharva-vpc-public-sub"
  }
}

resource "aws_subnet" "atharva_vpc_private_sub" {
  vpc_id = aws_vpc.atharva_vpc.id
  cidr_block = var.priv_sub_cidr
  availability_zone = "ap-south-1b"
  tags = {
    Name = "atharva-vpc-private-sub"
  }
}

# Route table creation
resource "aws_route_table" "atharva_vpc_public_rt" {
  vpc_id = aws_vpc.atharva_vpc.id
  route {
    cidr_block = "0.0.0.0/16"
    gateway_id = aws_internet_gateway.atharva_vpc_igw.id
  }
  tags = {
    Name = "atharva-vpc-public-rt"
  }
}


# Route table association
resource "aws_route_table_association" "name" {
  subnet_id = aws_subnet.atharva_vpc_public_sub.id
  route_table_id = aws_route_table.atharva_vpc_public_rt.id
}
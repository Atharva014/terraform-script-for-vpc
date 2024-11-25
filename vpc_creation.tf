terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.77.0"
    }
  }
}

provider "aws" {
  
}

resource "aws_vpc" "atharva_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "atharva-vpc"
  }
}

resource "aws_internet_gateway" "atharva_vpc_igw" {
  vpc_id = aws_vpc.atharva_vpc.id
  tags = {
    Name = "atharva-vpc-igw"
  }
}

resource "aws_subnet" "atharva_vpc_public_sub" {
  vpc_id = aws_vpc.atharva_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "atharva-vpc-public-sub"
  }
}

resource "aws_subnet" "atharva_vpc_private_sub" {
  vpc_id = aws_vpc.atharva_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "atharva-vpc-private-sub"
  }
}

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

resource "aws_route_table_association" "name" {
  subnet_id = aws_subnet.atharva_vpc_public_sub.id
  route_table_id = aws_route_table.atharva_vpc_public_rt.id
}
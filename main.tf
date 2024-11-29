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
  enable_resource_name_dns_a_record_on_launch = true
  tags = {
    Name = "atharva-vpc-public-sub"
  }
}

resource "aws_subnet" "atharva_vpc_private_sub" {
  vpc_id = aws_vpc.atharva_vpc.id
  cidr_block = var.priv_sub_cidr
  availability_zone = "ap-south-1b"
  enable_resource_name_dns_a_record_on_launch = true
  tags = {
    Name = "atharva-vpc-private-sub"
  }
}

# Elastic ip creation
resource "aws_eip" "atharva_vpc_eip" {
  domain = "vpc"
}

# NAT getway creation
resource "aws_nat_gateway" "atharva_vpc_ngw" {
  allocation_id = aws_eip.atharva_vpc_eip.id
  subnet_id = aws_subnet.atharva_vpc_public_sub.id
  tags = {
    Name = "atharva-vpc-bgw"
  }
  depends_on = [ aws_internet_gateway.atharva_vpc_igw ]
}

# Route table creation
resource "aws_route_table" "atharva_vpc_public_rt" {
  vpc_id = aws_vpc.atharva_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.atharva_vpc_igw.id
  }
  tags = {
    Name = "atharva-vpc-public-rt"
  }
}

resource "aws_route_table" "atharva_vpc_private_rt" {
  vpc_id = aws_vpc.atharva_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.atharva_vpc_ngw.id
  }
  tags = {
    Name = "atharva-vpc-private-rt"
  }
}

# Route table association
resource "aws_route_table_association" "pub_rt_association" {
  subnet_id = aws_subnet.atharva_vpc_public_sub.id
  route_table_id = aws_route_table.atharva_vpc_public_rt.id
}

resource "aws_route_table_association" "pri_rt_association" {
  subnet_id = aws_subnet.atharva_vpc_private_sub.id
  route_table_id = aws_route_table.atharva_vpc_private_rt.id
}

# Security Group creation
resource "aws_security_group" "atharva_vpc_sg" {
  name = "atharva_vpc_ssh_sg"
  description = "Allow ssh traffic from outside"
  vpc_id = aws_vpc.atharva_vpc.id
  tags = {
    Name = "allow_ssh"
  }
}

# Security Group rules creation
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_traffic" {
  security_group_id = aws_security_group.atharva_vpc_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "tcp"
  to_port = 22
  from_port = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.atharva_vpc_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

# Launch instance
resource "aws_instance" "public_web_srv" {
  ami = "ami-0614680123427b75e"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.atharva_vpc_public_sub.id
  tags = {
    Name = "linux-web-srv"
  }
  vpc_security_group_ids = [
    aws_security_group.atharva_vpc_sg.id
  ]
}

resource "aws_instance" "private_db_srv" {
  ami = "ami-0614680123427b75e"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.atharva_vpc_private_sub.id
  tags = {
    Name = "linux-wdb-srv"
  }
  vpc_security_group_ids = [
    aws_security_group.atharva_vpc_sg.id
  ]
}
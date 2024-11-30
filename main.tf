# VPC creation
resource "aws_vpc" "atharva_vpc" {
  cidr_block = var.vpc_cidr_block
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
  availability_zone = var.pub_sub_az
  enable_resource_name_dns_a_record_on_launch = true
  tags = {
    Name = "atharva-vpc-public-sub"
  }
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

# Route table association
resource "aws_route_table_association" "pub_rt_association" {
  subnet_id = aws_subnet.atharva_vpc_public_sub.id
  route_table_id = aws_route_table.atharva_vpc_public_rt.id
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
  count = var.no_of_instance
  ami = "ami-0614680123427b75e"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.atharva_vpc_public_sub.id
  key_name = "linux-key"
  tags = {
    Name = "linux-web-srv-${count.index + 1}"
  }
  vpc_security_group_ids = [
    aws_security_group.atharva_vpc_sg.id
  ]
  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp2"
  }
}

# Create additional volume
resource "aws_ebs_volume" "additional_vol" {
  count = var.no_of_instance * (var.no_of_ebs_per_instance - 1)
  availability_zone = var.pub_sub_az
  size = var.additional_volume_size
  type = "gp2"
  tags = {
    Name = "additional-volume-${count.index + 1}"
  }
}

# Attach volume to instance
resource "aws_volume_attachment" "attach_volume" {
  count = var.no_of_instance * (var.no_of_ebs_per_instance - 1)
  volume_id = aws_ebs_volume.additional_vol[count.index].id
  instance_id = aws_instance.public_web_srv[floor(count.index / (var.no_of_ebs_per_instance - 1))].id
  device_name = "/dev/xvd${element(["f", "g", "h", "i", "j", "k", "l", "m", "n", "o"], count.index % (var.no_of_ebs_per_instance - 1))}"
}
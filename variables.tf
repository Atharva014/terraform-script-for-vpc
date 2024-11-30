variable "aws_region" {
  type = string
  default = "ap-south-1"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
  type = string
  description = "CIDR for VPC"
}

variable "pub_sub_cidr" {
  default = "10.0.1.0/24"
  type = string
  description = "CIDR for public subnet"
}

variable "pub_sub_az" {
  default = "ap-south-1a"
  type = string
  description = "AZ for public subnet"
}

variable "root_volume_size" {
  type = number
  default = 10
}

variable "additional_volume_size" {
  type = number
  default = 5
}

variable "no_of_instance" {
  type = number
  default = 2
}

variable "no_of_ebs_per_instance" {
  type = number
  default = 2
}


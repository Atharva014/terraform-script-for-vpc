variable "vpc_cidr" {
  default = "10.0.0.0/16"
  type = string
  description = "CIDR for VPC"
}

variable "pub_sub_cidr" {
  default = "10.0.1.0/24"
  type = string
  description = "CIDR for public subnet"
}

variable "priv_sub_cidr" {
  default = "10.0.2.0/24"
  type = string
  description = "CIDR for private subnet"
}
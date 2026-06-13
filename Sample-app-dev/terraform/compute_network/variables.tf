variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
  default     = "leave-api-vpc"
}

variable "igw_name" {
  description = "Name tag for the Internet Gateway"
  type        = string
  default     = "leave-api-igw"
}

variable "public_subnet_name" {
  description = "Name tag for the public subnet"
  type        = string
  default     = "leave-api-public-subnet"
}

variable "private_subnet_name" {
  description = "Name tag for the private subnet"
  type        = string
  default     = "leave-api-private-subnet"
}

variable "route_table_1_name" {
  description = "Name tag for the public route table"
  type        = string
  default     = "leave-api-rt-public"
}

variable "route_table_2_name" {
  description = "Name tag for the private route table"
  type        = string
  default     = "leave-api-rt-private"
}

variable "sec_grp_name" {
  description = "Name tag for the public security group"
  type        = string
  default     = "leave-api-sg-public"
}

variable "sec_priv_grp_name" {
  description = "Name tag for the private security group"
  type        = string
  default     = "leave-api-sg-private"
}

variable "eip_name" {
  description = "Name tag for the Elastic IP"
  type        = string
  default     = "leave-api-eip"
}

variable "nat_gateway_name" {
  description = "Name tag for the NAT Gateway"
  type        = string
  default     = "leave-api-nat"
}

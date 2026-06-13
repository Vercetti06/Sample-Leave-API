resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.igw_name
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_name
  }
}

resource "aws_route_table" "rut_1" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = var.route_table_1_name
  }
}

resource "aws_route_table_association" "rut_1_assos" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rut_1.id
}

resource "aws_security_group" "security_grps_1" {
  vpc_id      = aws_vpc.vpc.id
  description = "defining the security groups for public subnets"

  tags = {
    Name = var.sec_grp_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_secur" {
  for_each          = toset(["80", "443"])
  security_group_id = aws_security_group.security_grps_1.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = each.value
  to_port     = each.value
}

resource "aws_vpc_security_group_egress_rule" "egress_secur" {
  security_group_id = aws_security_group.security_grps_1.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


# ==================== PRIVATE SUBNETS DECLARATION ====================

resource "aws_eip" "eip" {
  domain = "vpc"
  tags = {
    Name = var.eip_name
  }
}

resource "aws_nat_gateway" "nat_gtwy" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet.id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = var.nat_gateway_name
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  cidr_block              = "10.0.1.0/24"

  tags = {
    Name = var.private_subnet_name
  }
}

resource "aws_route_table" "rut_2" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gtwy.id
  }
  tags = {
    Name = var.route_table_2_name
  }
}

resource "aws_route_table_association" "rut_2_assos" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.rut_2.id
}

resource "aws_security_group" "security_grps_2" {
  vpc_id      = aws_vpc.vpc.id
  description = "defining the security groups for private subnets"

  tags = {
    Name = var.sec_priv_grp_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_secur-1" {
  for_each                     = toset(["22", "8080", "9000"])
  security_group_id            = aws_security_group.security_grps_2.id
  referenced_security_group_id = aws_security_group.security_grps_1.id

  ip_protocol = "tcp"
  from_port   = each.value
  to_port     = each.value
}

resource "aws_vpc_security_group_egress_rule" "egress_secur-1" {
  security_group_id = aws_security_group.security_grps_2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


data "aws_caller_identity" "current" {}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.environment}-vpc"
    Description = "VPC for ${var.environment} environment"
  }
}

resource "aws_subnet" "subnet" {
  for_each                = var.subnet
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = {
    Name = each.key
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  vpc_id            = aws_vpc.vpc.id
  availability_mode = "regional"

  tags = {
    Name = "${var.environment}-nat-gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.environment}-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${var.environment}-private-rt"
  }
}

resource "aws_route_table_association" "associations" {
  for_each       = aws_subnet.subnet
  subnet_id      = each.value.id
  route_table_id = var.subnet[each.key].map_public_ip_on_launch ? aws_route_table.public.id : aws_route_table.private.id
}

resource "aws_security_group" "security_group" {
  for_each = var.security_groups
  vpc_id   = aws_vpc.vpc.id
  name     = each.value.name

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      protocol        = ingress.value.protocol
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      cidr_blocks     = ingress.value.cidr_ipv4
      security_groups = ingress.value.sg
      description     = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = coalesce(each.value.egress, {})
    content {
      protocol        = egress.value.protocol
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      cidr_blocks     = egress.value.cidr_ipv4
      security_groups = egress.value.sg
      description     = egress.value.description
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
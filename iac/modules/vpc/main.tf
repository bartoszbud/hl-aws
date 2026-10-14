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

resource "aws_flow_log" "flow_logs" {
  vpc_id               = aws_vpc.vpc.id
  traffic_type         = "REJECT"
  log_destination_type = "s3"
  log_destination      = ""
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
}

resource "aws_eip" "eip" {
  domain = "vpc"

  tags = {
    Name = "${var.environment}-eip"
  }
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
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
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
output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The ID of the VPC"
}

output "subnet_ids" {
  value       = [for subnet in aws_subnet.subnet : subnet.id]
  description = "List of subnet IDs"
}

output "security_group_ids" {
  value       = [for security_group in aws_security_group.security_group : security_group.id]
  description = "List of security group IDs"
}

output "nat_gateway_id" {
  value       = aws_nat_gateway.nat_gateway.id
  description = "The ID of the NAT Gateway"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.igw.id
  description = "The ID of the Internet Gateway"
}

output "public_route_table_id" {
  value       = aws_route_table.public.id
  description = "The ID of the public route table"
}

output "private_route_table_id" {
  value       = aws_route_table.private.id
  description = "The ID of the private route table"
}
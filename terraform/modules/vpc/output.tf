output "vpc_prv_subnet_id" {
  description = "Private VPC Subnet"
  value       = aws_subnet.private_subnet.id
}

output "vpc_id" {
  description = "Application VPC"
  value       = aws_vpc.app_vpc.id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = aws_vpc.app_vpc.cidr_block
}

output "atlas_security_group_id" {
  description = "Atlas Security Group"
  value       = aws_security_group.endpoint_sg.id
}

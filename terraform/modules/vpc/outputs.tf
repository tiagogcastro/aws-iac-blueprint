# terraform/modules/vpc/outputs.tf
# Exported values from the VPC module consumed by dependent modules.

output "aws_vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}

output "aws_vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "aws_subnet_public_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "aws_subnet_private_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "aws_internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.this.id
}

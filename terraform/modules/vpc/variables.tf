# terraform/modules/vpc/variables.tf
# Input variable declarations for the VPC module.

variable "project_name" {
  description = "Project name used as prefix for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets, one per availability zone"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets, one per availability zone"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones for subnet placement; must match the length of both subnet CIDR lists"
  type        = list(string)
}

variable "tags" {
  description = "Additional tags merged onto all resources (base tags come from the provider default_tags)"
  type        = map(string)
  default     = {}
}

# Input variable declarations for the VPC module.

variable "project_name" {
  description = "Project name used as prefix for resource naming"
  type        = string
}

variable "deployment_environment" {
  description = "Deployment environment used in the VPC resource names"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_public_subnet_cidrs" {
  description = "CIDR blocks for public subnets, one per availability zone"
  type        = list(string)
}

variable "vpc_private_subnet_cidrs" {
  description = "CIDR blocks for private subnets, one per availability zone"
  type        = list(string)
}

variable "vpc_availability_zones" {
  description = "Availability zones for subnet placement; must match the length of both subnet CIDR lists"
  type        = list(string)
}

variable "resource_tags" {
  description = "Additional tags merged onto all resources (base tags come from the provider default_tags)"
  type        = map(string)
  default     = {}
}

# terraform/modules/iam/variables.tf
# Input variable declarations for the IAM module.

variable "project_name" {
  description = "Project name used as prefix for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "role_suffix" {
  description = "Suffix that identifies the role purpose, appended after the project-environment prefix"
  type        = string
}

variable "trusted_services" {
  description = "AWS service principals allowed to assume this role via sts:AssumeRole"
  type        = list(string)
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket this role will have read/write access to"
  type        = string
}

variable "tags" {
  description = "Additional tags merged onto all resources (base tags come from the provider default_tags)"
  type        = map(string)
  default     = {}
}

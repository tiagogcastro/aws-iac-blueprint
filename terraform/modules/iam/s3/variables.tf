# Inputs for the S3 IAM role and policy.

variable "project_name" {
  description = "Project name used in the S3 IAM resource names"
  type        = string
}

variable "deployment_environment" {
  description = "Deployment environment used in the S3 IAM resource names"
  type        = string
}

variable "s3_access_role_suffix" {
  description = "Suffix appended to the S3 access role name"
  type        = string
}

variable "s3_trusted_service_principals" {
  description = "AWS service principals allowed to assume the S3 access role"
  type        = list(string)
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket accessed by the role"
  type        = string
}

variable "resource_tags" {
  description = "Additional tags applied to the S3 IAM resources"
  type        = map(string)
  default     = {}
}

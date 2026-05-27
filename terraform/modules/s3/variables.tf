# terraform/modules/s3/variables.tf
# Input variable declarations for the S3 module.

variable "project_name" {
  description = "Project name used as prefix for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "bucket_suffix" {
  description = "Suffix appended to the bucket name to identify its purpose (e.g., raw, processed, curated)"
  type        = string
}

variable "layer" {
  description = "Data  layer this bucket represents: raw, processed, or curated"
  type        = string

  validation {
    condition     = contains(["raw", "processed", "curated"], var.layer)
    error_message = "layer must be one of: raw, processed, curated."
  }
}

variable "versioning_enabled" {
  description = "Enable S3 versioning for object history and point-in-time recovery"
  type        = bool
}

variable "tags" {
  description = "Additional tags merged onto all resources (base tags come from the provider default_tags)"
  type        = map(string)
  default     = {}
}

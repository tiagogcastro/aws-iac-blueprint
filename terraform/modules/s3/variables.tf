# Input variable declarations for the S3 module.

variable "project_name" {
  description = "Project name used as prefix for resource naming"
  type        = string
}

variable "deployment_environment" {
  description = "Deployment environment used in the S3 bucket name"
  type        = string
}

variable "s3_bucket_suffix" {
  description = "Suffix appended to the bucket name to identify its purpose (e.g., raw, processed, curated)"
  type        = string
}

variable "s3_data_layer" {
  description = "Data layer represented by the S3 bucket: raw, processed, or curated"
  type        = string

  validation {
    condition     = contains(["raw", "processed", "curated"], var.s3_data_layer)
    error_message = "s3_data_layer must be one of: raw, processed, curated."
  }
}

variable "s3_versioning_enabled" {
  description = "Enable S3 versioning for object history and point-in-time recovery"
  type        = bool
}

variable "resource_tags" {
  description = "Additional tags merged onto all resources (base tags come from the provider default_tags)"
  type        = map(string)
  default     = {}
}

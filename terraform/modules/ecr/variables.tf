# Inputs for the application image repository.

variable "project_name" {
  description = "Project name used in the ECR repository name"
  type        = string
}

variable "deployment_environment" {
  description = "Deployment environment used in the ECR repository name"
  type        = string
}

variable "ecr_repository_suffix" {
  description = "Suffix identifying the purpose of the ECR repository"
  type        = string
}

variable "ecr_image_tag_mutability" {
  description = "Whether existing ECR image tags can be overwritten"
  type        = string

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.ecr_image_tag_mutability)
    error_message = "ecr_image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "ecr_scan_on_push" {
  description = "Whether ECR scans container images after they are pushed"
  type        = bool
}

variable "ecr_encryption_type" {
  description = "Encryption type used for ECR images"
  type        = string

  validation {
    condition     = contains(["AES256", "KMS"], var.ecr_encryption_type)
    error_message = "ecr_encryption_type must be AES256 or KMS."
  }
}

variable "ecr_force_delete" {
  description = "Whether the ECR repository can be deleted while it contains images"
  type        = bool
}

variable "ecr_max_image_count" {
  description = "Maximum number of images retained by the ECR lifecycle policy"
  type        = number

  validation {
    condition     = var.ecr_max_image_count > 0
    error_message = "ecr_max_image_count must be greater than zero."
  }
}

variable "resource_tags" {
  description = "Additional tags applied to the ECR repository"
  type        = map(string)
  default     = {}
}

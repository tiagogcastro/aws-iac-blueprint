# Inputs for the EKS control plane and node IAM resources.

variable "project_name" {
  description = "Project name used in the EKS IAM resource names"
  type        = string
}

variable "deployment_environment" {
  description = "Deployment environment used in the EKS IAM resource names"
  type        = string
}

variable "resource_tags" {
  description = "Additional tags applied to the EKS IAM resources"
  type        = map(string)
  default     = {}
}

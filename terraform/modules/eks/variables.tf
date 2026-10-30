# Inputs for the EKS cluster and managed node group.

variable "project_name" {
  description = "Project name used in the EKS cluster and node group names"
  type        = string
}

variable "deployment_environment" {
  description = "Deployment environment used in the EKS cluster and node group names"
  type        = string
}

variable "eks_kubernetes_version" {
  description = "Kubernetes version used by the EKS control plane"
  type        = string
}

variable "eks_cluster_role_arn" {
  description = "IAM role ARN used by the EKS control plane"
  type        = string
}

variable "eks_node_role_arn" {
  description = "IAM role ARN used by the EKS node group"
  type        = string
}

variable "eks_subnet_ids" {
  description = "Private subnet IDs used by the EKS cluster and managed node group"
  type        = list(string)

  validation {
    condition     = length(var.eks_subnet_ids) >= 2
    error_message = "EKS requires at least two subnets."
  }
}

variable "eks_endpoint_public_access" {
  description = "Whether the EKS control plane endpoint is reachable outside the VPC"
  type        = bool
}

variable "eks_endpoint_private_access" {
  description = "Whether the EKS control plane endpoint is reachable from within the VPC"
  type        = bool
}

variable "eks_node_capacity_type" {
  description = "Capacity purchasing model used by the EKS managed node group"
  type        = string

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.eks_node_capacity_type)
    error_message = "eks_node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "eks_node_instance_types" {
  description = "EC2 instance types used by the EKS managed node group"
  type        = list(string)
}

variable "eks_node_desired_size" {
  description = "Desired number of nodes in the EKS managed node group"
  type        = number
}

variable "eks_node_min_size" {
  description = "Minimum number of nodes in the EKS managed node group"
  type        = number
}

variable "eks_node_max_size" {
  description = "Maximum number of nodes in the EKS managed node group"
  type        = number
}

variable "resource_tags" {
  description = "Additional tags applied to the EKS cluster and managed node group"
  type        = map(string)
  default     = {}
}

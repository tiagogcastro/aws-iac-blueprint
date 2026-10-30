# Inputs for the EKS cluster and managed node group.

variable "project_name" {
  description = "Project name used in the EKS cluster and node group names"
  type        = string
}

variable "deployment_environment" {
  description = "Deployment environment used in the EKS cluster and node group names"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version used by the EKS control plane"
  type        = string
  default     = "1.31"
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

variable "eks_node_instance_types" {
  description = "EC2 instance types used by the EKS managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_desired_size" {
  description = "Desired number of nodes in the EKS managed node group"
  type        = number
  default     = 1
}

variable "eks_node_min_size" {
  description = "Minimum number of nodes in the EKS managed node group"
  type        = number
  default     = 1
}

variable "eks_node_max_size" {
  description = "Maximum number of nodes in the EKS managed node group"
  type        = number
  default     = 2
}

variable "resource_tags" {
  description = "Additional tags applied to the EKS cluster and managed node group"
  type        = map(string)
  default     = {}
}

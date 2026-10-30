# EKS identifiers exported to dependent infrastructure.

output "aws_eks_cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.project_cluster.name
}

output "aws_eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.project_cluster.arn
}

output "aws_eks_cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = aws_eks_cluster.project_cluster.endpoint
}

output "aws_eks_cluster_oidc_issuer" {
  description = "OIDC issuer used by Kubernetes workload identity"
  value       = try(aws_eks_cluster.project_cluster.identity[0].oidc[0].issuer, "")
}

output "aws_eks_cluster_version" {
  description = "Kubernetes version"
  value       = aws_eks_cluster.project_cluster.version
}

output "aws_eks_node_group_name" {
  description = "Managed node group name"
  value       = aws_eks_node_group.managed_nodes.node_group_name
}

output "aws_eks_cluster_role_arn" {
  description = "Cluster IAM role ARN"
  value       = var.eks_cluster_role_arn
}

output "aws_eks_node_role_arn" {
  description = "Node IAM role ARN"
  value       = var.eks_node_role_arn
}

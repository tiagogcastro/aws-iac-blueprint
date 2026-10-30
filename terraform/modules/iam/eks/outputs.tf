# Role and policy identifiers consumed by the EKS module.

output "aws_iam_eks_cluster_role_name" {
  description = "Name of the IAM role used by the EKS control plane"
  value       = aws_iam_role.eks_cluster.name
}

output "aws_iam_eks_cluster_role_arn" {
  description = "ARN of the IAM role used by the EKS control plane"
  value       = aws_iam_role.eks_cluster.arn
}

output "aws_iam_eks_node_role_name" {
  description = "Name of the IAM role used by the EKS managed node group"
  value       = aws_iam_role.eks_node.name
}

output "aws_iam_eks_node_role_arn" {
  description = "ARN of the IAM role used by the EKS managed node group"
  value       = aws_iam_role.eks_node.arn
}

output "aws_iam_eks_ecr_pull_policy_arn" {
  description = "ARN of the IAM policy that allows ECR image pulls"
  value       = aws_iam_policy.eks_ecr_pull.arn
}

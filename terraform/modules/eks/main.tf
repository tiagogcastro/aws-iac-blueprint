# EKS cluster and managed node group configuration.

locals {
  eks_cluster_name = "${var.project_name}-${var.deployment_environment}"
}

resource "aws_eks_cluster" "project_cluster" {
  name     = local.eks_cluster_name
  role_arn = var.eks_cluster_role_arn
  version  = var.eks_kubernetes_version

  vpc_config {
    subnet_ids              = var.eks_subnet_ids
    endpoint_public_access  = var.eks_endpoint_public_access
    endpoint_private_access = var.eks_endpoint_private_access
  }

  tags = merge(var.resource_tags, {
    Name = local.eks_cluster_name
  })
}

resource "aws_eks_node_group" "managed_nodes" {
  cluster_name    = aws_eks_cluster.project_cluster.name
  node_group_name = "${local.eks_cluster_name}-nodes"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = var.eks_subnet_ids
  instance_types  = var.eks_node_instance_types
  capacity_type   = var.eks_node_capacity_type

  scaling_config {
    desired_size = var.eks_node_desired_size
    min_size     = var.eks_node_min_size
    max_size     = var.eks_node_max_size
  }

  tags = merge(var.resource_tags, {
    Name = "${local.eks_cluster_name}-nodes"
  })
}

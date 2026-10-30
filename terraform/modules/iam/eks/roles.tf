# IAM roles used by the EKS control plane and managed node group.

locals {
  eks_cluster_role_name = "${var.project_name}-${var.deployment_environment}-eks-cluster-role"
  eks_node_role_name    = "${var.project_name}-${var.deployment_environment}-eks-node-role"
}

data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  name               = local.eks_cluster_role_name
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json

  tags = merge(var.resource_tags, {
    Name = local.eks_cluster_role_name
  })
}

data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node" {
  name               = local.eks_node_role_name
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json

  tags = merge(var.resource_tags, {
    Name = local.eks_node_role_name
  })
}

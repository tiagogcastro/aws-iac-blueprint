# ECR pull policy used by the EKS managed node group.

locals {
  eks_ecr_pull_policy_name = "${var.project_name}-${var.deployment_environment}-eks-ecr-pull"
}

data "aws_iam_policy_document" "eks_ecr_pull" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "eks_ecr_pull" {
  name        = local.eks_ecr_pull_policy_name
  description = "Allows the EKS managed node group to pull container images from ECR"
  policy      = data.aws_iam_policy_document.eks_ecr_pull.json

  tags = merge(var.resource_tags, {
    Name = local.eks_ecr_pull_policy_name
  })
}

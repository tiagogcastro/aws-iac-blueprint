# Shared EKS configuration and its VPC and IAM dependencies.

terraform {
  source = "${get_repo_root()}/terraform/modules/eks"
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  environment = local.environment_vars.locals
  global      = local.global_vars.locals
}

dependency "vpc_network" {
  config_path = "${get_repo_root()}/terragrunt/live/${local.environment.environment}/vpc"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "hclvalidate", "plan"]
  mock_outputs = {
    aws_subnet_private_ids = ["subnet-00000001", "subnet-00000002"]
  }
}

dependency "eks_iam" {
  config_path = "${get_repo_root()}/terragrunt/live/${local.environment.environment}/iam/eks"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "hclvalidate", "plan"]
  mock_outputs = {
    aws_iam_eks_cluster_role_arn = "arn:aws:iam::${local.environment.aws_account_id}:role/${local.global.project_name}-${local.environment.environment}-eks-cluster-role"
    aws_iam_eks_node_role_arn    = "arn:aws:iam::${local.environment.aws_account_id}:role/${local.global.project_name}-${local.environment.environment}-eks-node-role"
  }
}

inputs = {
  project_name                = local.global.project_name
  deployment_environment      = local.environment.environment
  eks_kubernetes_version      = local.environment.eks_kubernetes_version
  eks_cluster_role_arn        = dependency.eks_iam.outputs.aws_iam_eks_cluster_role_arn
  eks_node_role_arn           = dependency.eks_iam.outputs.aws_iam_eks_node_role_arn
  eks_subnet_ids              = dependency.vpc_network.outputs.aws_subnet_private_ids
  eks_endpoint_public_access  = local.environment.eks_endpoint_public_access
  eks_endpoint_private_access = local.environment.eks_endpoint_private_access
  eks_node_capacity_type      = local.environment.eks_node_capacity_type
  eks_node_instance_types     = local.environment.eks_node_instance_types
  eks_node_desired_size       = local.environment.eks_node_desired_size
  eks_node_min_size           = local.environment.eks_node_min_size
  eks_node_max_size           = local.environment.eks_node_max_size
  resource_tags               = local.environment.extra_tags
}

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
    aws_iam_eks_cluster_role_arn = "arn:aws:iam::000000000000:role/blueprint-dev-eks-cluster-role"
    aws_iam_eks_node_role_arn    = "arn:aws:iam::000000000000:role/blueprint-dev-eks-node-role"
  }
}

inputs = {
  project_name            = local.global.project_name
  deployment_environment  = local.environment.environment
  kubernetes_version      = "1.31"
  eks_cluster_role_arn    = dependency.eks_iam.outputs.aws_iam_eks_cluster_role_arn
  eks_node_role_arn       = dependency.eks_iam.outputs.aws_iam_eks_node_role_arn
  eks_subnet_ids          = dependency.vpc_network.outputs.aws_subnet_private_ids
  eks_node_instance_types = ["t3.medium"]
  eks_node_desired_size   = 1
  eks_node_min_size       = 1
  eks_node_max_size       = 2
  resource_tags           = local.environment.extra_tags
}

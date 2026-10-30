# Dev entry point for the EKS control plane and node IAM resources.

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "environment_common" {
  path   = "${get_repo_root()}/terragrunt/_common/iam/eks/terragrunt.hcl"
  expose = true
}

terraform {
  source = include.environment_common.terraform.source
}

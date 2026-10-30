# Dev entry point for the EKS cluster and managed node group.

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path   = "${get_repo_root()}/terragrunt/_common/eks/terragrunt.hcl"
  expose = true
}

terraform {
  source = include.envcommon.terraform.source
}

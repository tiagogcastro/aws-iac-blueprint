# Dev entry point for the application image repository.

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "environment_common" {
  path   = "${get_repo_root()}/terragrunt/_common/ecr/terragrunt.hcl"
  expose = true
}

terraform {
  source = include.environment_common.terraform.source
}

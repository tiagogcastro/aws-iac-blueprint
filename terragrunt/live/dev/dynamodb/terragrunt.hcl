include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path   = "${get_repo_root()}/terragrunt/_common/dynamodb/terragrunt.hcl"
  expose = true
}

terraform {
  source = include.envcommon.terraform.source
}

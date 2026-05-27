# terragrunt/live/dev/iam/terragrunt.hcl
# Dev IAM entry point — wires root.hcl and _common/iam together for the dev environment.

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path   = "${get_repo_root()}/terragrunt/_common/iam/terragrunt.hcl"
  expose = true
}

terraform {
  source = include.envcommon.terraform.source
}

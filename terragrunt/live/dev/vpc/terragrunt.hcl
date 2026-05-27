# terragrunt/live/dev/vpc/terragrunt.hcl
# Dev VPC entry point — wires root.hcl and _common/vpc together for the dev environment.

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path   = "${get_repo_root()}/terragrunt/_common/vpc/terragrunt.hcl"
  expose = true
}

terraform {
  source = include.envcommon.terraform.source
}

# terragrunt/live/dev/s3/terragrunt.hcl
# Dev S3 entry point — wires root.hcl and _common/s3 together for the dev environment.

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path   = "${get_repo_root()}/terragrunt/_common/s3/terragrunt.hcl"
  expose = true
}

terraform {
  source = include.envcommon.terraform.source
}

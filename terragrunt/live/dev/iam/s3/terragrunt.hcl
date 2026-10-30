# Dev entry point for the S3 IAM role and policy.

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "environment_common" {
  path   = "${get_repo_root()}/terragrunt/_common/iam/s3/terragrunt.hcl"
  expose = true
}

terraform {
  source = include.environment_common.terraform.source
}

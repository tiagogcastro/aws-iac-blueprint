# terragrunt/_common/s3/terragrunt.hcl
# Shared S3 module configuration — source path and inputs applied to every environment.

terraform {
  source = "${get_repo_root()}/terraform/modules/s3"
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  env    = local.environment_vars.locals
  global = local.global_vars.locals
}

inputs = {
  project_name       = local.global.project_name
  environment        = local.env.environment
  bucket_suffix      = "raw"
  layer              = "raw"
  versioning_enabled = true
  tags               = local.env.extra_tags
}

# Shared S3 module configuration — source path and inputs applied to every environment.

terraform {
  source = "${get_repo_root()}/terraform/modules/s3"
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  environment = local.environment_vars.locals
  global      = local.global_vars.locals
}

inputs = {
  project_name           = local.global.project_name
  deployment_environment = local.environment.environment
  s3_bucket_suffix       = local.environment.s3_bucket_suffix
  s3_data_layer          = local.environment.s3_data_layer
  s3_versioning_enabled  = local.environment.s3_versioning_enabled
  resource_tags          = local.environment.extra_tags
}

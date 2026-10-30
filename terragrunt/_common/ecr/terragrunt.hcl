# Shared ECR configuration mapped from each environment.

terraform {
  source = "${get_repo_root()}/terraform/modules/ecr"
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  environment = local.environment_vars.locals
  global      = local.global_vars.locals
}

inputs = {
  project_name             = local.global.project_name
  deployment_environment   = local.environment.environment
  ecr_repository_suffix    = local.environment.ecr_repository_suffix
  ecr_image_tag_mutability = local.environment.ecr_image_tag_mutability
  ecr_scan_on_push         = local.environment.ecr_scan_on_push
  ecr_encryption_type      = local.environment.ecr_encryption_type
  ecr_force_delete         = local.environment.ecr_force_delete
  ecr_max_image_count      = local.environment.ecr_max_image_count
  resource_tags            = local.environment.extra_tags
}

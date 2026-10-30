# Shared configuration for the EKS control plane and node IAM resources.

terraform {
  source = "${get_repo_root()}/terraform/modules/iam/eks"
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
  resource_tags          = local.environment.extra_tags
}

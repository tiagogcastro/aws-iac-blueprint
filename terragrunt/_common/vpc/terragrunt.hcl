# Shared VPC module configuration — source path and inputs applied to every environment.

terraform {
  source = "${get_repo_root()}/terraform/modules/vpc"
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
  vpc_cidr                 = local.environment.vpc_cidr
  vpc_public_subnet_cidrs  = local.environment.vpc_public_subnet_cidrs
  vpc_private_subnet_cidrs = local.environment.vpc_private_subnet_cidrs
  vpc_availability_zones   = local.environment.vpc_availability_zones
  resource_tags            = local.environment.extra_tags
}

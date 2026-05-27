# terragrunt/_common/vpc/terragrunt.hcl
# Shared VPC module configuration — source path and inputs applied to every environment.

terraform {
  source = "${get_repo_root()}/terraform/modules/vpc"
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  env    = local.environment_vars.locals
  global = local.global_vars.locals
}

inputs = {
  project_name         = local.global.project_name
  environment          = local.env.environment
  vpc_cidr             = local.env.vpc_cidr
  public_subnet_cidrs  = local.env.public_subnet_cidrs
  private_subnet_cidrs = local.env.private_subnet_cidrs
  availability_zones   = local.env.availability_zones
  tags                 = local.env.extra_tags
}

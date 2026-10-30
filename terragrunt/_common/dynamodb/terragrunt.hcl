terraform {
  source = "${get_repo_root()}/terraform/modules/dynamodb"
}

locals {
  environment = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  global      = read_terragrunt_config(find_in_parent_folders("global.hcl")).locals
}

inputs = {
  project_name                 = local.global.project_name
  deployment_environment       = local.environment.environment
  dynamodb_files_table_suffix  = local.environment.dynamodb_files_table_suffix
  dynamodb_events_table_suffix = local.environment.dynamodb_events_table_suffix
  dynamodb_billing_mode        = local.environment.dynamodb_billing_mode
  dynamodb_events_ttl_enabled  = local.environment.dynamodb_events_ttl_enabled
  resource_tags                = local.environment.extra_tags
}

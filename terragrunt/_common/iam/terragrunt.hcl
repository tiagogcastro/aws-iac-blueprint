# terragrunt/_common/iam/terragrunt.hcl
# Shared IAM module configuration — source path, S3 dependency, and inputs applied to every environment.

terraform {
  source = "${get_repo_root()}/terraform/modules/iam"
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  env    = local.environment_vars.locals
  global = local.global_vars.locals
}

dependency "s3" {
  config_path  = "${get_repo_root()}/terragrunt/live/${local.env.environment}/s3"
  skip_outputs = false

  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "hclvalidate", "plan"]

  mock_outputs = {
    aws_s3_bucket_arn = "arn:aws:s3:::blueprint-${local.env.environment}-raw"
  }
}

inputs = {
  project_name     = local.global.project_name
  environment      = local.env.environment
  role_suffix      = "s3-raw-role"
  trusted_services = ["ec2.amazonaws.com"]
  s3_bucket_arn    = dependency.s3.outputs.aws_s3_bucket_arn
  tags             = local.env.extra_tags
}

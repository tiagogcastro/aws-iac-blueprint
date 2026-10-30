# Shared configuration for the S3 IAM role and policy.

terraform {
  source = "${get_repo_root()}/terraform/modules/iam/s3"
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  environment = local.environment_vars.locals
  global      = local.global_vars.locals
}

dependency "s3_bucket" {
  config_path = "${get_repo_root()}/terragrunt/live/${local.environment.environment}/s3"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "hclvalidate", "plan"]
  mock_outputs = {
    aws_s3_bucket_arn = "arn:aws:s3:::blueprint-${local.environment.environment}-raw"
  }
}

inputs = {
  project_name                  = local.global.project_name
  deployment_environment        = local.environment.environment
  s3_access_role_suffix         = "s3-raw-role"
  s3_trusted_service_principals = ["ec2.amazonaws.com"]
  s3_bucket_arn                 = dependency.s3_bucket.outputs.aws_s3_bucket_arn
  resource_tags                 = local.environment.extra_tags
}

# terragrunt/root.hcl
# Included by every child terragrunt.hcl. Generates versions.tf, provider.tf, and backend.tf per module.

locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  project_name = local.global_vars.locals.project_name
  owner        = local.global_vars.locals.owner
  environment  = local.env_vars.locals.environment
  aws_region   = local.env_vars.locals.aws_region

  skip_credentials_validation = local.env_vars.locals.skip_credentials_validation
  skip_metadata_api_check     = local.env_vars.locals.skip_metadata_api_check
  skip_requesting_account_id  = local.env_vars.locals.skip_requesting_account_id

  localstack_endpoint = local.env_vars.locals.localstack_endpoint
}

# Generates versions.tf — the single source of truth for provider version constraints.
# Modules themselves carry no terraform{} block; Terragrunt injects this file into
# every module's working directory inside .terragrunt-cache.
generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_version = ">= 1.5.0"

      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 5.0"
        }
      }
    }
  EOF
}

# Generates provider.tf — AWS provider config injected into every module's cache directory.
# When LOCALSTACK_ENDPOINT is set, an endpoints{} block is injected automatically so
# every AWS API call is redirected to LocalStack — no code change needed.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.aws_region}"

      skip_credentials_validation = ${local.skip_credentials_validation}
      skip_metadata_api_check     = ${local.skip_metadata_api_check}
      skip_requesting_account_id  = ${local.skip_requesting_account_id}
      %{~ if local.localstack_endpoint != "" }

      s3_use_path_style = true

      endpoints {
        s3  = "${local.localstack_endpoint}"
        iam = "${local.localstack_endpoint}"
        ec2 = "${local.localstack_endpoint}"
        sts = "${local.localstack_endpoint}"
      }
      %{~ endif }

      default_tags {
        tags = {
          Project     = "${local.project_name}"
          Environment = "${local.environment}"
          Owner       = "${local.owner}"
          ManagedBy   = "terraform"
        }
      }
    }
  EOF
}

# Local backend — no remote state, no S3 bucket required.
# To migrate to a real backend, replace this block with an S3 remote_state config.
remote_state {
  backend = "local"

  config = {
    path = "${get_terragrunt_dir()}/.terraform/terraform.tfstate"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

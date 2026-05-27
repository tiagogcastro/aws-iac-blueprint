# terragrunt/global.hcl
# Project-wide constants (project name, owner, provider skip-flags) shared across all environments.

locals {
  project_name = "blueprint"
  owner        = "tiago"
}

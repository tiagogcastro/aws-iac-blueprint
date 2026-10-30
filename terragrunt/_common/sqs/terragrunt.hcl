terraform {
  source = "${get_repo_root()}/terraform/modules/sqs"
}

locals {
  environment = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  global      = read_terragrunt_config(find_in_parent_folders("global.hcl")).locals
}

inputs = {
  project_name                   = local.global.project_name
  deployment_environment         = local.environment.environment
  sqs_queue_suffix               = local.environment.sqs_queue_suffix
  sqs_dlq_suffix                 = local.environment.sqs_dlq_suffix
  sqs_visibility_timeout_seconds = local.environment.sqs_visibility_timeout_seconds
  sqs_message_retention_seconds  = local.environment.sqs_message_retention_seconds
  sqs_receive_wait_time_seconds  = local.environment.sqs_receive_wait_time_seconds
  sqs_max_receive_count          = local.environment.sqs_max_receive_count
  resource_tags                  = local.environment.extra_tags
}

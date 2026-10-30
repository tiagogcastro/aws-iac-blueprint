terraform {
  source = "${get_repo_root()}/terraform/modules/iam/fileflow"
}

locals {
  environment = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  global      = read_terragrunt_config(find_in_parent_folders("global.hcl")).locals
}

dependency "eks" {
  config_path                             = "${get_repo_root()}/terragrunt/live/${local.environment.environment}/eks"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "hclvalidate", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs                            = { aws_eks_cluster_oidc_issuer = "https://oidc.eks.${local.environment.aws_region}.amazonaws.com/id/local" }
}

dependency "s3" {
  config_path                             = "${get_repo_root()}/terragrunt/live/${local.environment.environment}/s3"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "hclvalidate", "plan"]
  mock_outputs                            = { aws_s3_bucket_arn = "arn:aws:s3:::${local.global.project_name}-${local.environment.environment}-${local.environment.s3_bucket_suffix}" }
}

dependency "dynamodb" {
  config_path                             = "${get_repo_root()}/terragrunt/live/${local.environment.environment}/dynamodb"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "hclvalidate", "plan"]
  mock_outputs = {
    aws_dynamodb_files_table_arn  = "arn:aws:dynamodb:${local.environment.aws_region}:${local.environment.aws_account_id}:table/files"
    aws_dynamodb_events_table_arn = "arn:aws:dynamodb:${local.environment.aws_region}:${local.environment.aws_account_id}:table/events"
  }
}

dependency "sqs" {
  config_path                             = "${get_repo_root()}/terragrunt/live/${local.environment.environment}/sqs"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "hclvalidate", "plan"]
  mock_outputs                            = { aws_sqs_processing_queue_arn = "arn:aws:sqs:${local.environment.aws_region}:${local.environment.aws_account_id}:processing" }
}

inputs = {
  project_name           = local.global.project_name
  deployment_environment = local.environment.environment
  eks_oidc_issuer        = dependency.eks.outputs.aws_eks_cluster_oidc_issuer
  oidc_thumbprint        = local.environment.fileflow_oidc_thumbprint
  kubernetes_namespace   = local.environment.fileflow_kubernetes_namespace
  api_service_account    = local.environment.fileflow_api_service_account
  worker_service_account = local.environment.fileflow_worker_service_account
  s3_bucket_arn          = dependency.s3.outputs.aws_s3_bucket_arn
  files_table_arn        = dependency.dynamodb.outputs.aws_dynamodb_files_table_arn
  events_table_arn       = dependency.dynamodb.outputs.aws_dynamodb_events_table_arn
  processing_queue_arn   = dependency.sqs.outputs.aws_sqs_processing_queue_arn
  resource_tags          = local.environment.extra_tags
}

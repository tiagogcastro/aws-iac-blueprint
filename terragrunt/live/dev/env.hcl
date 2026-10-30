# Dev environment values for the provider and provisioned services.

locals {
  environment    = "dev"
  aws_region     = "us-east-1"
  aws_account_id = "000000000000"

  # Set to false when targeting a real AWS account.
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # Extra tags applied per resource alongside the provider default_tags.
  # Project / Environment / Owner / ManagedBy are already in default_tags — do not repeat them.
  extra_tags = {
    CostCenter = "engineering"
  }

  # Set AWS_ENDPOINT_URL=http://localhost:4566 to redirect AWS API calls to MiniStack.
  # Leave unset (or empty) to target real AWS.
  # prod/env.hcl should not declare this variable.
  aws_endpoint = get_env("AWS_ENDPOINT_URL", "")

  # VPC capacity and addressing.
  vpc_cidr                 = "10.0.0.0/16"
  vpc_public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  vpc_private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  vpc_availability_zones   = ["us-east-1a", "us-east-1b"]

  # S3 data classification and recovery behavior.
  s3_bucket_suffix      = "raw"
  s3_data_layer         = "raw"
  s3_versioning_enabled = true

  # FileFlow metadata and processing history.
  dynamodb_files_table_suffix  = "fileflow-files"
  dynamodb_events_table_suffix = "fileflow-events"
  dynamodb_billing_mode        = "PAY_PER_REQUEST"
  dynamodb_events_ttl_enabled  = false

  # Asynchronous file processing and failed-message retention.
  sqs_queue_suffix               = "fileflow-processing"
  sqs_dlq_suffix                 = "fileflow-processing-dlq"
  sqs_visibility_timeout_seconds = 60
  sqs_message_retention_seconds  = 345600
  sqs_receive_wait_time_seconds  = 20
  sqs_max_receive_count          = 3

  # IAM access to the S3 bucket.
  s3_access_role_suffix         = "s3-raw-role"
  s3_trusted_service_principals = ["ec2.amazonaws.com"]

  # ECR image integrity, scanning, encryption, and retention.
  ecr_repository_suffix    = "fileflow"
  ecr_image_tag_mutability = "IMMUTABLE"
  ecr_scan_on_push         = true
  ecr_encryption_type      = "AES256"
  ecr_force_delete         = true
  ecr_max_image_count      = 10

  # EKS control plane access and managed node group capacity.
  eks_kubernetes_version      = "1.31"
  eks_endpoint_public_access  = true
  eks_endpoint_private_access = true
  eks_node_capacity_type      = "ON_DEMAND"
  eks_node_instance_types     = ["t3.medium"]
  eks_node_desired_size       = 1
  eks_node_min_size           = 1
  eks_node_max_size           = 2

  # Kubernetes workload identity. Replace the local thumbprint in real AWS.
  fileflow_kubernetes_namespace   = "fileflow"
  fileflow_api_service_account    = "fileflow-api"
  fileflow_worker_service_account = "fileflow-worker"
  fileflow_oidc_thumbprint        = "0000000000000000000000000000000000000000"
}

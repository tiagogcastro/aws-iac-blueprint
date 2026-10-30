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
}

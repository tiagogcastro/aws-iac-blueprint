# Dev environment variables — region, account ID, networking CIDRs, tags, and local AWS endpoint.

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

  # Networking — adjust per environment to avoid CIDR conflicts between dev / staging / prod.
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
}

# IAM role that grants an AWS service access to the S3 bucket.

locals {
  s3_access_role_name = "${var.project_name}-${var.deployment_environment}-${var.s3_access_role_suffix}"
}

data "aws_iam_policy_document" "s3_access_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = var.s3_trusted_service_principals
    }
  }
}

resource "aws_iam_role" "s3_access" {
  name               = local.s3_access_role_name
  assume_role_policy = data.aws_iam_policy_document.s3_access_assume_role.json

  tags = merge(var.resource_tags, {
    Name = local.s3_access_role_name
  })
}

# Least-privilege policy for bucket and object operations.

locals {
  s3_access_policy_name = "${local.s3_access_role_name}-s3-policy"
}

data "aws_iam_policy_document" "s3_access" {
  statement {
    sid     = "AllowBucketListing"
    effect  = "Allow"
    actions = ["s3:ListBucket", "s3:GetBucketLocation"]

    resources = [var.s3_bucket_arn]
  }

  statement {
    sid     = "AllowObjectOperations"
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]

    resources = ["${var.s3_bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "s3_access" {
  name        = local.s3_access_policy_name
  description = "Allows listing the S3 bucket and reading, writing, and deleting its objects"
  policy      = data.aws_iam_policy_document.s3_access.json

  tags = merge(var.resource_tags, {
    Name = local.s3_access_policy_name
  })
}

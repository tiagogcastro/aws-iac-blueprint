# terraform/modules/iam/main.tf
# IAM role with a least-privilege S3 access policy and role-policy attachment.

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = var.trusted_services
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.project_name}-${var.environment}-${var.role_suffix}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-${var.role_suffix}"
  })
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
  name        = "${var.project_name}-${var.environment}-${var.role_suffix}-s3-policy"
  description = "Grants read/write access to the target S3 bucket"
  policy      = data.aws_iam_policy_document.s3_access.json

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-${var.role_suffix}-s3-policy"
  })
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.s3_access.arn
}

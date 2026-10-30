# Separate workload identities for the FileFlow API and background worker.

locals {
  oidc_url         = replace(var.eks_oidc_issuer, "http://", "https://")
  oidc_hostpath    = replace(local.oidc_url, "https://", "")
  api_role_name    = "${var.project_name}-${var.deployment_environment}-fileflow-api-role"
  worker_role_name = "${var.project_name}-${var.deployment_environment}-fileflow-worker-role"
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = local.oidc_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.oidc_thumbprint]

  tags = merge(var.resource_tags, { Name = "${var.project_name}-${var.deployment_environment}-eks-oidc" })
}

data "aws_iam_policy_document" "api_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_hostpath}:sub"
      values   = ["system:serviceaccount:${var.kubernetes_namespace}:${var.api_service_account}"]
    }
  }
}

data "aws_iam_policy_document" "worker_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_hostpath}:sub"
      values   = ["system:serviceaccount:${var.kubernetes_namespace}:${var.worker_service_account}"]
    }
  }
}

resource "aws_iam_role" "api" {
  name               = local.api_role_name
  assume_role_policy = data.aws_iam_policy_document.api_assume.json
  tags               = merge(var.resource_tags, { Name = local.api_role_name })
}

resource "aws_iam_role" "worker" {
  name               = local.worker_role_name
  assume_role_policy = data.aws_iam_policy_document.worker_assume.json
  tags               = merge(var.resource_tags, { Name = local.worker_role_name })
}

data "aws_iam_policy_document" "api" {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${var.s3_bucket_arn}/*"]
  }
  statement {
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem", "dynamodb:Query"]
    resources = [var.files_table_arn, "${var.files_table_arn}/index/*", var.events_table_arn]
  }
  statement {
    actions   = ["sqs:SendMessage"]
    resources = [var.processing_queue_arn]
  }
}

data "aws_iam_policy_document" "worker" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${var.s3_bucket_arn}/*"]
  }
  statement {
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem"]
    resources = [var.files_table_arn, var.events_table_arn]
  }
  statement {
    actions   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:ChangeMessageVisibility", "sqs:GetQueueAttributes"]
    resources = [var.processing_queue_arn]
  }
}

resource "aws_iam_role_policy" "api" {
  name   = "${local.api_role_name}-policy"
  role   = aws_iam_role.api.id
  policy = data.aws_iam_policy_document.api.json
}

resource "aws_iam_role_policy" "worker" {
  name   = "${local.worker_role_name}-policy"
  role   = aws_iam_role.worker.id
  policy = data.aws_iam_policy_document.worker.json
}

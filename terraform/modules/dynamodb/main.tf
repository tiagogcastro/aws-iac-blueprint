# DynamoDB tables for current file state and append-only processing history.

locals {
  files_table_name  = "${var.project_name}-${var.deployment_environment}-${var.dynamodb_files_table_suffix}"
  events_table_name = "${var.project_name}-${var.deployment_environment}-${var.dynamodb_events_table_suffix}"
}

resource "aws_dynamodb_table" "files" {
  name         = local.files_table_name
  billing_mode = var.dynamodb_billing_mode
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "owner_id"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  global_secondary_index {
    name            = "owner-created-at-index"
    hash_key        = "owner_id"
    range_key       = "created_at"
    projection_type = "ALL"
  }

  tags = merge(var.resource_tags, { Name = local.files_table_name })
}

resource "aws_dynamodb_table" "events" {
  name         = local.events_table_name
  billing_mode = var.dynamodb_billing_mode
  hash_key     = "file_id"
  range_key    = "occurred_at"

  attribute {
    name = "file_id"
    type = "S"
  }

  attribute {
    name = "occurred_at"
    type = "S"
  }

  dynamic "ttl" {
    for_each = var.dynamodb_events_ttl_enabled ? [1] : []
    content {
      attribute_name = "expires_at"
      enabled        = true
    }
  }

  tags = merge(var.resource_tags, { Name = local.events_table_name })
}

# File processing queue with a dead-letter queue for exhausted retries.

locals {
  queue_name = "${var.project_name}-${var.deployment_environment}-${var.sqs_queue_suffix}"
  dlq_name   = "${var.project_name}-${var.deployment_environment}-${var.sqs_dlq_suffix}"
}

resource "aws_sqs_queue" "dead_letter" {
  name                      = local.dlq_name
  message_retention_seconds = var.sqs_message_retention_seconds

  tags = merge(var.resource_tags, { Name = local.dlq_name })
}

resource "aws_sqs_queue" "processing" {
  name                       = local.queue_name
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
  message_retention_seconds  = var.sqs_message_retention_seconds
  receive_wait_time_seconds  = var.sqs_receive_wait_time_seconds

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter.arn
    maxReceiveCount     = var.sqs_max_receive_count
  })

  tags = merge(var.resource_tags, { Name = local.queue_name })
}

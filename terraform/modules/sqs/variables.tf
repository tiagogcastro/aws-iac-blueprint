variable "project_name" {
  description = "Project name used in queue names"
  type        = string
}

variable "deployment_environment" {
  description = "Environment used in queue names"
  type        = string
}

variable "sqs_queue_suffix" {
  description = "Processing queue suffix"
  type        = string
}

variable "sqs_dlq_suffix" {
  description = "Dead-letter queue suffix"
  type        = string
}

variable "sqs_visibility_timeout_seconds" {
  description = "Time a received message remains invisible"
  type        = number
}

variable "sqs_message_retention_seconds" {
  description = "Message retention period"
  type        = number
}

variable "sqs_receive_wait_time_seconds" {
  description = "Long-poll wait time"
  type        = number
}

variable "sqs_max_receive_count" {
  description = "Attempts before a message moves to the DLQ"
  type        = number
}

variable "resource_tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}

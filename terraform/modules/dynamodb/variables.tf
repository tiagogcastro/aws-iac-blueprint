variable "project_name" {
  description = "Project name used in table names"
  type        = string
}

variable "deployment_environment" {
  description = "Environment used in table names"
  type        = string
}

variable "dynamodb_files_table_suffix" {
  description = "Suffix for the file metadata table"
  type        = string
}

variable "dynamodb_events_table_suffix" {
  description = "Suffix for the file event history table"
  type        = string
}

variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "dynamodb_events_ttl_enabled" {
  description = "Whether event history expires through DynamoDB TTL"
  type        = bool
  default     = false
}

variable "resource_tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}

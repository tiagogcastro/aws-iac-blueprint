output "aws_dynamodb_files_table_name" {
  description = "File metadata table name"
  value       = aws_dynamodb_table.files.name
}

output "aws_dynamodb_files_table_arn" {
  description = "File metadata table ARN"
  value       = aws_dynamodb_table.files.arn
}

output "aws_dynamodb_events_table_name" {
  description = "File event history table name"
  value       = aws_dynamodb_table.events.name
}

output "aws_dynamodb_events_table_arn" {
  description = "File event history table ARN"
  value       = aws_dynamodb_table.events.arn
}

output "aws_sqs_processing_queue_name" {
  description = "Processing queue name"
  value       = aws_sqs_queue.processing.name
}

output "aws_sqs_processing_queue_url" {
  description = "Processing queue URL"
  value       = aws_sqs_queue.processing.url
}

output "aws_sqs_processing_queue_arn" {
  description = "Processing queue ARN"
  value       = aws_sqs_queue.processing.arn
}

output "aws_sqs_dead_letter_queue_name" {
  description = "Dead-letter queue name"
  value       = aws_sqs_queue.dead_letter.name
}

output "aws_sqs_dead_letter_queue_url" {
  description = "Dead-letter queue URL"
  value       = aws_sqs_queue.dead_letter.url
}

output "aws_sqs_dead_letter_queue_arn" {
  description = "Dead-letter queue ARN"
  value       = aws_sqs_queue.dead_letter.arn
}

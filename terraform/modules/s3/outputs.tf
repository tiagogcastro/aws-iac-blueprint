# terraform/modules/s3/outputs.tf
# Exported values from the S3 module consumed by dependent modules (e.g., IAM).

output "aws_s3_bucket_id" {
  description = "Name (ID) of the S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "aws_s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "aws_s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

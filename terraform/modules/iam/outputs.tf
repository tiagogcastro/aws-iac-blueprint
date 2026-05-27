# terraform/modules/iam/outputs.tf
# Exported values from the IAM module.

output "aws_iam_role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.this.name
}

output "aws_iam_role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.this.arn
}

output "aws_iam_policy_arn" {
  description = "ARN of the S3 access IAM policy"
  value       = aws_iam_policy.s3_access.arn
}

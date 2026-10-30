# Identifiers exported for services that use the S3 access role.

output "aws_iam_s3_access_role_name" {
  description = "Name of the IAM role that grants access to the S3 bucket"
  value       = aws_iam_role.s3_access.name
}

output "aws_iam_s3_access_role_arn" {
  description = "ARN of the IAM role that grants access to the S3 bucket"
  value       = aws_iam_role.s3_access.arn
}

output "aws_iam_s3_access_policy_arn" {
  description = "ARN of the IAM policy that grants access to the S3 bucket"
  value       = aws_iam_policy.s3_access.arn
}

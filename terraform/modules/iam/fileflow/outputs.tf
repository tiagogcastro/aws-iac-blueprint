output "aws_iam_fileflow_api_role_arn" {
  value = aws_iam_role.api.arn
}

output "aws_iam_fileflow_worker_role_arn" {
  value = aws_iam_role.worker.arn
}

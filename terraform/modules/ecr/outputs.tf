# ECR identifiers consumed by image publishing and deployment workflows.

output "aws_ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.application_images.name
}

output "aws_ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.application_images.arn
}

output "aws_ecr_repository_url" {
  description = "URL used to tag and push container images"
  value       = aws_ecr_repository.application_images.repository_url
}

output "aws_ecr_registry_id" {
  description = "AWS account ID of the ECR registry"
  value       = aws_ecr_repository.application_images.registry_id
}

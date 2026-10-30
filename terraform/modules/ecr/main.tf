# ECR repository for application container images.

locals {
  ecr_repository_name = "${var.project_name}-${var.deployment_environment}-${var.ecr_repository_suffix}"
}

resource "aws_ecr_repository" "application_images" {
  name                 = local.ecr_repository_name
  image_tag_mutability = var.ecr_image_tag_mutability
  force_delete         = var.ecr_force_delete

  image_scanning_configuration {
    scan_on_push = var.ecr_scan_on_push
  }

  encryption_configuration {
    encryption_type = var.ecr_encryption_type
  }

  tags = merge(var.resource_tags, {
    Name = local.ecr_repository_name
  })
}

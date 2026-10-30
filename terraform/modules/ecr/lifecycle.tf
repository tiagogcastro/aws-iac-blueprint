# Removes old images after the environment-specific retention count is exceeded.

resource "aws_ecr_lifecycle_policy" "application_images" {
  repository = aws_ecr_repository.application_images.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep the most recent ${var.ecr_max_image_count} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.ecr_max_image_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

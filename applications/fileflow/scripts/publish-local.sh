#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(git rev-parse --show-toplevel)
APP_DIR="$ROOT_DIR/applications/fileflow"
REGISTRY="localhost:4566"

export AWS_ENDPOINT_URL="${AWS_ENDPOINT_URL:-http://localhost:4566}"
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-test}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-test}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"

REPOSITORY=$(terragrunt --working-dir "$ROOT_DIR/terragrunt/live/dev/ecr" output -raw aws_ecr_repository_name)

docker build -t fileflow:dev "$APP_DIR"
IMAGE_ID=$(docker image inspect fileflow:dev --format '{{.Id}}' | sed 's/^sha256://')
TAG="dev-${IMAGE_ID:0:12}"
TARGET="$REGISTRY/$REPOSITORY:$TAG"

if aws ecr describe-images --repository-name "$REPOSITORY" --image-ids "imageTag=$TAG" >/dev/null 2>&1; then
  echo "Image already published: $TARGET"
  exit 0
fi

aws ecr get-login-password | docker login --username AWS --password-stdin "$REGISTRY"
docker tag fileflow:dev "$TARGET"
docker push "$TARGET"

echo "FileFlow published: $TARGET"

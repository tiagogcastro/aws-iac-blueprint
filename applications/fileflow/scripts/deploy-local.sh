#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(git rev-parse --show-toplevel)
APP_DIR="$ROOT_DIR/applications/fileflow"
CLUSTER_CONTAINER="ministack-eks-000000000000-us-east-1-blueprint-dev"

export AWS_ENDPOINT_URL="${AWS_ENDPOINT_URL:-http://localhost:4566}"
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-test}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-test}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"

output() {
  terragrunt --working-dir "$ROOT_DIR/terragrunt/live/dev/$1" output -raw "$2"
}

docker build -t fileflow:dev "$APP_DIR"
IMAGE="fileflow:local-$(docker image inspect fileflow:dev --format '{{.Id}}' | sed 's/^sha256://' | cut -c1-12)"
docker tag fileflow:dev "$IMAGE"
docker save "$IMAGE" | docker exec -i "$CLUSTER_CONTAINER" ctr --namespace k8s.io images import -

MINISTACK_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ministack-iac-blueprint)
S3_BUCKET=$(output s3 aws_s3_bucket_id)
FILES_TABLE=$(output dynamodb aws_dynamodb_files_table_name)
EVENTS_TABLE=$(output dynamodb aws_dynamodb_events_table_name)
QUEUE_URL=$(output sqs aws_sqs_processing_queue_url | sed "s|localhost|$MINISTACK_IP|")
API_ROLE_ARN=$(output iam/fileflow aws_iam_fileflow_api_role_arn)
WORKER_ROLE_ARN=$(output iam/fileflow aws_iam_fileflow_worker_role_arn)

sed \
  -e "s|__IMAGE__|$IMAGE|g" \
  -e "s|__AWS_ENDPOINT__|http://$MINISTACK_IP:4566|g" \
  -e "s|__S3_BUCKET__|$S3_BUCKET|g" \
  -e "s|__FILES_TABLE__|$FILES_TABLE|g" \
  -e "s|__EVENTS_TABLE__|$EVENTS_TABLE|g" \
  -e "s|__QUEUE_URL__|$QUEUE_URL|g" \
  -e "s|__API_ROLE_ARN__|$API_ROLE_ARN|g" \
  -e "s|__WORKER_ROLE_ARN__|$WORKER_ROLE_ARN|g" \
  "$APP_DIR/deploy/kubernetes/fileflow.yaml.tpl" \
  | docker exec -i "$CLUSTER_CONTAINER" kubectl apply -f -

docker exec "$CLUSTER_CONTAINER" kubectl rollout status deployment/fileflow-api -n fileflow --timeout=120s
docker exec "$CLUSTER_CONTAINER" kubectl rollout status deployment/fileflow-worker -n fileflow --timeout=120s

echo "FileFlow deployed. NodePort: http://$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CLUSTER_CONTAINER"):30080"

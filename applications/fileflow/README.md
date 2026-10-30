# FileFlow

FileFlow is the demonstrable workload for this infrastructure blueprint. One Go image runs in two modes: an HTTP API and an asynchronous worker. S3 stores file bytes, DynamoDB stores metadata and history, and SQS with a DLQ decouples uploads from processing.

## Runtime flow

```text
POST /api/files
  → S3 object
  → DynamoDB metadata (QUEUED)
  → SQS job
  → worker (PROCESSING)
  → SHA-256 + DynamoDB history (READY)
```

Processing states are `QUEUED`, `PROCESSING`, `READY`, `FAILED`, and `DELETED`.

## Code map

| Path | Responsibility |
|---|---|
| `cmd/fileflow/main.go` | Wires dependencies and starts `api` or `worker` |
| `internal/files` | Domain models, ports, and use-case orchestration |
| `internal/objectstore` | S3 adapter for file bytes |
| `internal/repository` | DynamoDB adapter for metadata and events |
| `internal/jobs` | SQS publishing and consumption |
| `internal/worker` | Background processing and SHA-256 calculation |
| `internal/httpapi` | Routes and HTTP request/response handling |
| `webui` | Temporary embedded browser interface |

The `files.Service` depends on small interfaces rather than AWS SDK clients. AWS-specific behavior stays in adapters, while the service expresses the upload, query, download, and deletion rules.

## API

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/healthz` | Liveness and readiness check |
| `GET` | `/api/files` | List active files |
| `POST` | `/api/files` | Upload multipart field `file` |
| `GET` | `/api/files/{id}` | Get metadata and processing status |
| `GET` | `/api/files/{id}/content` | Display content inline; add `?download=true` to download |
| `GET` | `/api/files/{id}/events` | Get processing history |
| `DELETE` | `/api/files/{id}` | Delete the S3 object and mark metadata deleted |

## Deploy locally to EKS

After applying the `dev` Terragrunt environment:

```bash
applications/fileflow/scripts/deploy-local.sh
```

The script builds a non-root image, assigns a content-derived local tag, imports it into k3s containerd, renders the Kubernetes template, and waits for two API replicas and one worker. It prints the NodePort URL when ready.

Publish the same image to the local immutable ECR repository with:

```bash
applications/fileflow/scripts/publish-local.sh
```

## Configuration

| Variable | Default | Description |
|---|---:|---|
| `PORT` | `8080` | API HTTP port |
| `MAX_UPLOAD_BYTES` | `20971520` | Maximum file size (20 MiB) |
| `AWS_REGION` | `us-east-1` | AWS region |
| `AWS_ENDPOINT_URL` | empty | MiniStack endpoint; empty uses AWS |
| `S3_BUCKET` | required | Object bucket |
| `DYNAMODB_FILES_TABLE` | required | Metadata table |
| `DYNAMODB_EVENTS_TABLE` | required | History table |
| `SQS_QUEUE_URL` | required | Processing queue URL |
| `FILEFLOW_OWNER_ID` | `public` | Temporary owner until authentication is added |

The local Kubernetes deployment supplies fake credentials because MiniStack does not enforce IAM. Service Accounts still carry separate API and worker role annotations so the same workload boundary can use IRSA on AWS.

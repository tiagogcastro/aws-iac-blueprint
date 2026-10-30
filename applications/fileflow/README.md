# FileFlow

FileFlow is the demonstrable workload for this infrastructure blueprint. A single Go binary serves a responsive web interface and a small file API. The current storage adapter uses a local directory; a later phase will replace it with S3 through workload identity.

## Code map

| Path | Responsibility | Go concept |
|---|---|---|
| `cmd/fileflow/main.go` | Connect configuration, storage, and HTTP server | Program entry point |
| `internal/config` | Read environment variables | Structs and functions |
| `internal/files/store.go` | Describe storage operations | Interfaces |
| `internal/files/local.go` | Save and read files on disk | Methods, files, and errors |
| `internal/httpapi/server.go` | Register URL routes | `http.Handler` |
| `internal/httpapi/handlers.go` | Handle API requests | Request/response flow |
| `webui` | Embed and serve the browser interface | `embed.FS` |

The module path in `go.mod` is the repository URL. Imports such as `github.com/tiagogcastro/.../internal/files` are the standard Go convention and allow the module to be downloaded and built from any machine.

## API

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/healthz` | Liveness check |
| `GET` | `/api/files` | List files |
| `POST` | `/api/files` | Upload multipart field `file` |
| `GET` | `/api/files/{id}` | Download a file |
| `DELETE` | `/api/files/{id}` | Delete a file |

## Run with Docker

```bash
docker build -t fileflow:local applications/fileflow
docker run --rm -p 8080:8080 -v fileflow-data:/data fileflow:local
```

Open <http://localhost:8080>.

To run directly with Go:

```bash
cd applications/fileflow
STORAGE_DIR=./data go run ./cmd/fileflow
```

## Configuration

| Variable | Default | Description |
|---|---:|---|
| `PORT` | `8080` | HTTP port |
| `STORAGE_DIR` | `/data` | Directory containing uploaded files |
| `MAX_UPLOAD_BYTES` | `20971520` | Maximum file size (20 MiB) |

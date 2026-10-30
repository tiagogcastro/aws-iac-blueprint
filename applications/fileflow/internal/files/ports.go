package files

import (
	"context"
	"io"
)

// ObjectStore owns the file bytes. The AWS implementation uses S3.
type ObjectStore interface {
	Put(ctx context.Context, key, contentType string, body io.Reader, size int64) error
	Open(ctx context.Context, key string) (io.ReadCloser, error)
	Delete(ctx context.Context, key string) error
}

// Repository owns queryable metadata and history. The AWS implementation uses DynamoDB.
type Repository interface {
	CreateFile(ctx context.Context, file File) error
	GetFile(ctx context.Context, id string) (File, error)
	ListFiles(ctx context.Context, ownerID string, limit int32) ([]File, error)
	UpdateStatus(ctx context.Context, id, status, sha256 string) error
	AddEvent(ctx context.Context, event Event) error
	ListEvents(ctx context.Context, fileID string) ([]Event, error)
}

// JobQueue decouples the upload request from background processing.
type JobQueue interface {
	Publish(ctx context.Context, job ProcessingJob) error
}

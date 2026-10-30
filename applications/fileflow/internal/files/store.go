package files

import (
	"context"
	"errors"
	"io"
	"time"
)

var ErrNotFound = errors.New("file not found")

// File is the information returned to the API and the web interface.
type File struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	ContentType string    `json:"contentType"`
	Size        int64     `json:"size"`
	UploadedAt  time.Time `json:"uploadedAt"`
}

type OpenedFile struct {
	File
	Content io.ReadCloser
}

// Store describes storage behavior without choosing disk or S3.
type Store interface {
	Save(ctx context.Context, name string, content io.Reader) (File, error)
	List(ctx context.Context) ([]File, error)
	Open(ctx context.Context, id string) (OpenedFile, error)
	Delete(ctx context.Context, id string) error
}

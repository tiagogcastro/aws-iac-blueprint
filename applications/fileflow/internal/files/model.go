package files

import (
	"io"
	"time"
)

const (
	StatusQueued     = "QUEUED"
	StatusProcessing = "PROCESSING"
	StatusReady      = "READY"
	StatusFailed     = "FAILED"
	StatusDeleted    = "DELETED"
)

type File struct {
	ID          string    `json:"id" dynamodbav:"id"`
	OwnerID     string    `json:"ownerId" dynamodbav:"owner_id"`
	Name        string    `json:"name" dynamodbav:"name"`
	ObjectKey   string    `json:"-" dynamodbav:"object_key"`
	ContentType string    `json:"contentType" dynamodbav:"content_type"`
	Category    string    `json:"category" dynamodbav:"category"`
	Status      string    `json:"status" dynamodbav:"status"`
	SHA256      string    `json:"sha256,omitempty" dynamodbav:"sha256,omitempty"`
	Size        int64     `json:"size" dynamodbav:"size"`
	CreatedAt   time.Time `json:"createdAt" dynamodbav:"created_at"`
	UpdatedAt   time.Time `json:"updatedAt" dynamodbav:"updated_at"`
}

type Event struct {
	FileID     string    `json:"fileId" dynamodbav:"file_id"`
	OccurredAt time.Time `json:"occurredAt" dynamodbav:"occurred_at"`
	Type       string    `json:"type" dynamodbav:"event_type"`
	Message    string    `json:"message" dynamodbav:"message"`
}

type Upload struct {
	Name        string
	ContentType string
	Size        int64
	Content     io.Reader
}

type Content struct {
	File
	Body io.ReadCloser
}

type ProcessingJob struct {
	FileID    string `json:"fileId"`
	ObjectKey string `json:"objectKey"`
}

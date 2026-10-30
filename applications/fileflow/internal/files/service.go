package files

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"path/filepath"
	"strings"
	"time"
)

var ErrNotFound = errors.New("file not found")

type Service struct {
	objects    ObjectStore
	repository Repository
	queue      JobQueue
	ownerID    string
}

func NewService(objects ObjectStore, repository Repository, queue JobQueue, ownerID string) *Service {
	return &Service{objects: objects, repository: repository, queue: queue, ownerID: ownerID}
}

func (s *Service) Upload(ctx context.Context, upload Upload) (File, error) {
	id, err := newID()
	if err != nil {
		return File{}, err
	}

	now := time.Now().UTC()
	name := safeName(upload.Name)
	file := File{
		ID: id, OwnerID: s.ownerID, Name: name,
		ObjectKey:   "files/" + id + "/" + name,
		ContentType: upload.ContentType, Category: "uncategorized",
		Status: StatusQueued, Size: upload.Size, CreatedAt: now, UpdatedAt: now,
	}

	if err := s.objects.Put(ctx, file.ObjectKey, file.ContentType, upload.Content, upload.Size); err != nil {
		return File{}, fmt.Errorf("upload object: %w", err)
	}
	if err := s.repository.CreateFile(ctx, file); err != nil {
		_ = s.objects.Delete(ctx, file.ObjectKey)
		return File{}, fmt.Errorf("create metadata: %w", err)
	}
	if err := s.addEvent(ctx, file.ID, "FILE_UPLOADED", "File stored and queued for processing"); err != nil {
		return File{}, err
	}
	if err := s.queue.Publish(ctx, ProcessingJob{FileID: file.ID, ObjectKey: file.ObjectKey}); err != nil {
		_ = s.repository.UpdateStatus(ctx, file.ID, StatusFailed, "")
		return File{}, fmt.Errorf("queue processing: %w", err)
	}
	return file, nil
}

func (s *Service) List(ctx context.Context) ([]File, error) {
	return s.repository.ListFiles(ctx, s.ownerID, 100)
}

func (s *Service) Get(ctx context.Context, id string) (File, error) {
	return s.repository.GetFile(ctx, id)
}

func (s *Service) Open(ctx context.Context, id string) (Content, error) {
	file, err := s.repository.GetFile(ctx, id)
	if err != nil {
		return Content{}, err
	}
	body, err := s.objects.Open(ctx, file.ObjectKey)
	if err != nil {
		return Content{}, fmt.Errorf("open object: %w", err)
	}
	return Content{File: file, Body: body}, nil
}

func (s *Service) Delete(ctx context.Context, id string) error {
	file, err := s.repository.GetFile(ctx, id)
	if err != nil {
		return err
	}
	if err := s.objects.Delete(ctx, file.ObjectKey); err != nil {
		return fmt.Errorf("delete object: %w", err)
	}
	if err := s.repository.UpdateStatus(ctx, id, StatusDeleted, ""); err != nil {
		return fmt.Errorf("mark deleted: %w", err)
	}
	return s.addEvent(ctx, id, "FILE_DELETED", "File removed from object storage")
}

func (s *Service) Events(ctx context.Context, id string) ([]Event, error) {
	return s.repository.ListEvents(ctx, id)
}

func (s *Service) addEvent(ctx context.Context, id, eventType, message string) error {
	event := Event{FileID: id, OccurredAt: time.Now().UTC(), Type: eventType, Message: message}
	return s.repository.AddEvent(ctx, event)
}

func newID() (string, error) {
	value := make([]byte, 16)
	if _, err := rand.Read(value); err != nil {
		return "", fmt.Errorf("create file ID: %w", err)
	}
	return hex.EncodeToString(value), nil
}

func safeName(name string) string {
	name = filepath.Base(strings.ReplaceAll(name, "\\", "/"))
	if name == "" || name == "." {
		return "file"
	}
	return name
}

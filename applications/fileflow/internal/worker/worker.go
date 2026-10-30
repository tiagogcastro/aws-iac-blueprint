package worker

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"io"
	"log/slog"
	"time"

	"github.com/tiagogcastro/aws-iac-blueprint/applications/fileflow/internal/files"
	"github.com/tiagogcastro/aws-iac-blueprint/applications/fileflow/internal/jobs"
)

type Worker struct {
	objects    files.ObjectStore
	repository files.Repository
	queue      *jobs.Queue
	logger     *slog.Logger
}

func New(objects files.ObjectStore, repository files.Repository, queue *jobs.Queue, logger *slog.Logger) *Worker {
	return &Worker{objects: objects, repository: repository, queue: queue, logger: logger}
}

func (w *Worker) Run(ctx context.Context) error {
	w.logger.Info("FileFlow worker started")
	for ctx.Err() == nil {
		message, err := w.queue.Receive(ctx)
		if err != nil {
			w.logger.Error("receive processing job", "error", err)
			continue
		}
		if message == nil {
			continue
		}
		if err := w.process(ctx, message.Job); err != nil {
			w.logger.Error("process file", "file_id", message.Job.FileID, "error", err)
			_ = w.repository.UpdateStatus(ctx, message.Job.FileID, files.StatusFailed, "")
			_ = w.addEvent(ctx, message.Job.FileID, "PROCESSING_FAILED", err.Error())
			continue
		}
		if err := w.queue.Delete(ctx, message.ReceiptHandle); err != nil {
			w.logger.Error("delete processed message", "error", err)
		}
	}
	return ctx.Err()
}

func (w *Worker) process(ctx context.Context, job files.ProcessingJob) error {
	if err := w.repository.UpdateStatus(ctx, job.FileID, files.StatusProcessing, ""); err != nil {
		return fmt.Errorf("mark processing: %w", err)
	}
	if err := w.addEvent(ctx, job.FileID, "PROCESSING_STARTED", "Worker started file analysis"); err != nil {
		return err
	}

	body, err := w.objects.Open(ctx, job.ObjectKey)
	if err != nil {
		return err
	}
	defer body.Close()

	hash := sha256.New()
	if _, err := io.Copy(hash, body); err != nil {
		return fmt.Errorf("calculate SHA-256: %w", err)
	}
	checksum := hex.EncodeToString(hash.Sum(nil))
	if err := w.repository.UpdateStatus(ctx, job.FileID, files.StatusReady, checksum); err != nil {
		return fmt.Errorf("mark ready: %w", err)
	}
	return w.addEvent(ctx, job.FileID, "PROCESSING_COMPLETED", "SHA-256 calculated successfully")
}

func (w *Worker) addEvent(ctx context.Context, fileID, eventType, message string) error {
	return w.repository.AddEvent(ctx, files.Event{
		FileID: fileID, OccurredAt: time.Now().UTC(), Type: eventType, Message: message,
	})
}

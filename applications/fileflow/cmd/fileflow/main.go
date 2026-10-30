package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/tiagogcastro/aws-iac-blueprint/applications/fileflow/internal/cloud"
	"github.com/tiagogcastro/aws-iac-blueprint/applications/fileflow/internal/config"
	"github.com/tiagogcastro/aws-iac-blueprint/applications/fileflow/internal/files"
	"github.com/tiagogcastro/aws-iac-blueprint/applications/fileflow/internal/httpapi"
	"github.com/tiagogcastro/aws-iac-blueprint/applications/fileflow/internal/jobs"
	"github.com/tiagogcastro/aws-iac-blueprint/applications/fileflow/internal/objectstore"
	"github.com/tiagogcastro/aws-iac-blueprint/applications/fileflow/internal/repository"
	"github.com/tiagogcastro/aws-iac-blueprint/applications/fileflow/internal/worker"
)

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	settings := config.Load()
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	clients, err := cloud.New(ctx, settings.AWSRegion, settings.AWSEndpoint)
	if err != nil {
		logger.Error("initialize AWS clients", "error", err)
		os.Exit(1)
	}

	objects := objectstore.NewS3(clients.S3, settings.S3Bucket)
	metadata := repository.NewDynamoDB(clients.DynamoDB, settings.FilesTable, settings.EventsTable)
	queue := jobs.NewQueue(clients.SQS, settings.QueueURL)

	if command() == "worker" {
		runner := worker.New(objects, metadata, queue, logger)
		if err := runner.Run(ctx); err != nil && !errors.Is(err, context.Canceled) {
			logger.Error("worker stopped", "error", err)
			os.Exit(1)
		}
		return
	}

	service := files.NewService(objects, metadata, queue, settings.OwnerID)
	runAPI(ctx, settings, service, logger)
}

func runAPI(ctx context.Context, settings config.Config, service *files.Service, logger *slog.Logger) {
	server := http.Server{
		Addr:              ":" + settings.Port,
		Handler:           httpapi.New(service, settings.MaxUploadBytes, logger),
		ReadHeaderTimeout: 5 * time.Second,
	}
	go func() {
		<-ctx.Done()
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		_ = server.Shutdown(shutdownCtx)
	}()

	logger.Info("FileFlow API started", "address", server.Addr)
	if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
		logger.Error("server stopped", "error", err)
		os.Exit(1)
	}
}

func command() string {
	if len(os.Args) > 1 {
		return os.Args[1]
	}
	return "api"
}

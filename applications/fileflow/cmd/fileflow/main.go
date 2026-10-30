package main

import (
	"log/slog"
	"net/http"
	"os"
	"time"

	"github.com/tiagogcastro/aws-iac-blueprint/applications/fileflow/internal/config"
	"github.com/tiagogcastro/aws-iac-blueprint/applications/fileflow/internal/files"
	"github.com/tiagogcastro/aws-iac-blueprint/applications/fileflow/internal/httpapi"
)

func main() {
	settings := config.Load()
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))

	store, err := files.NewLocalStore(settings.StorageDir)
	if err != nil {
		logger.Error("initialize storage", "error", err)
		os.Exit(1)
	}

	server := http.Server{
		Addr:              ":" + settings.Port,
		Handler:           httpapi.New(store, settings.MaxUploadBytes, logger),
		ReadHeaderTimeout: 5 * time.Second,
	}

	logger.Info("FileFlow started", "address", server.Addr)
	if err := server.ListenAndServe(); err != nil {
		logger.Error("server stopped", "error", err)
		os.Exit(1)
	}
}

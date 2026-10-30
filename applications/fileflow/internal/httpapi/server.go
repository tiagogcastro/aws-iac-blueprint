package httpapi

import (
	"log/slog"
	"net/http"

	"github.com/tiagogcastro/aws-iac-blueprint/applications/fileflow/internal/files"
	"github.com/tiagogcastro/aws-iac-blueprint/applications/fileflow/webui"
)

type server struct {
	service        *files.Service
	maxUploadBytes int64
	logger         *slog.Logger
}

func New(service *files.Service, maxUploadBytes int64, logger *slog.Logger) http.Handler {
	s := &server{service: service, maxUploadBytes: maxUploadBytes, logger: logger}
	router := http.NewServeMux()

	router.HandleFunc("GET /healthz", s.health)
	router.HandleFunc("GET /api/files", s.list)
	router.HandleFunc("POST /api/files", s.upload)
	router.HandleFunc("GET /api/files/{id}", s.get)
	router.HandleFunc("GET /api/files/{id}/content", s.download)
	router.HandleFunc("GET /api/files/{id}/events", s.events)
	router.HandleFunc("DELETE /api/files/{id}", s.delete)
	router.Handle("GET /", webui.Handler())

	return s.logRequests(router)
}

func (s *server) logRequests(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		s.logger.Info("HTTP request", "method", r.Method, "path", r.URL.Path)
		next.ServeHTTP(w, r)
	})
}

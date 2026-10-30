package httpapi

import (
	"errors"
	"fmt"
	"io"
	"mime"
	"net/http"

	"github.com/tiagogcastro/aws-iac-blueprint/applications/fileflow/internal/files"
)

func (s *server) health(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
}

func (s *server) list(w http.ResponseWriter, r *http.Request) {
	result, err := s.service.List(r.Context())
	if err != nil {
		s.internalError(w, "list files", err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"files": result})
}

func (s *server) upload(w http.ResponseWriter, r *http.Request) {
	r.Body = http.MaxBytesReader(w, r.Body, s.maxUploadBytes+(1<<20))
	part, header, err := r.FormFile("file")
	if err != nil {
		writeError(w, http.StatusBadRequest, "multipart field 'file' is required")
		return
	}
	defer part.Close()
	if header.Size > s.maxUploadBytes {
		writeError(w, http.StatusRequestEntityTooLarge, "file is too large")
		return
	}

	contentType := header.Header.Get("Content-Type")
	if contentType == "" {
		contentType = "application/octet-stream"
	}
	result, err := s.service.Upload(r.Context(), files.Upload{
		Name: header.Filename, ContentType: contentType, Size: header.Size,
		Content: part,
	})
	if err != nil {
		s.internalError(w, "upload file", err)
		return
	}
	writeJSON(w, http.StatusCreated, result)
}

func (s *server) get(w http.ResponseWriter, r *http.Request) {
	result, err := s.service.Get(r.Context(), r.PathValue("id"))
	if s.fileError(w, "get file", err) {
		return
	}
	writeJSON(w, http.StatusOK, result)
}

func (s *server) download(w http.ResponseWriter, r *http.Request) {
	result, err := s.service.Open(r.Context(), r.PathValue("id"))
	if s.fileError(w, "open file", err) {
		return
	}
	defer result.Body.Close()

	w.Header().Set("Content-Type", result.ContentType)
	w.Header().Set("Content-Length", fmt.Sprint(result.Size))
	disposition := "inline"
	if r.URL.Query().Get("download") == "true" {
		disposition = "attachment"
	}
	w.Header().Set("Content-Disposition", mime.FormatMediaType(disposition, map[string]string{"filename": result.Name}))
	_, _ = io.Copy(w, result.Body)
}

func (s *server) delete(w http.ResponseWriter, r *http.Request) {
	err := s.service.Delete(r.Context(), r.PathValue("id"))
	if s.fileError(w, "delete file", err) {
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (s *server) events(w http.ResponseWriter, r *http.Request) {
	result, err := s.service.Events(r.Context(), r.PathValue("id"))
	if err != nil {
		s.internalError(w, "list file events", err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"events": result})
}

func (s *server) fileError(w http.ResponseWriter, operation string, err error) bool {
	if errors.Is(err, files.ErrNotFound) {
		writeError(w, http.StatusNotFound, "file not found")
		return true
	}
	if err != nil {
		s.internalError(w, operation, err)
		return true
	}
	return false
}

func (s *server) internalError(w http.ResponseWriter, operation string, err error) {
	s.logger.Error(operation, "error", err)
	writeError(w, http.StatusInternalServerError, "internal server error")
}

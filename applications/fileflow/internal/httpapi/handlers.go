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
	result, err := s.store.List(r.Context())
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

	result, err := s.store.Save(r.Context(), header.Filename, io.LimitReader(part, s.maxUploadBytes+1))
	if err != nil {
		s.internalError(w, "save file", err)
		return
	}
	if result.Size > s.maxUploadBytes {
		_ = s.store.Delete(r.Context(), result.ID)
		writeError(w, http.StatusRequestEntityTooLarge, "file is too large")
		return
	}
	writeJSON(w, http.StatusCreated, result)
}

func (s *server) download(w http.ResponseWriter, r *http.Request) {
	result, err := s.store.Open(r.Context(), r.PathValue("id"))
	if s.fileError(w, "open file", err) {
		return
	}
	defer result.Content.Close()

	w.Header().Set("Content-Type", result.ContentType)
	w.Header().Set("Content-Length", fmt.Sprint(result.Size))
	w.Header().Set("Content-Disposition", mime.FormatMediaType("attachment", map[string]string{"filename": result.Name}))
	_, _ = io.Copy(w, result.Content)
}

func (s *server) delete(w http.ResponseWriter, r *http.Request) {
	err := s.store.Delete(r.Context(), r.PathValue("id"))
	if s.fileError(w, "delete file", err) {
		return
	}
	w.WriteHeader(http.StatusNoContent)
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

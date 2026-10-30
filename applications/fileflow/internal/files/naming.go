package files

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"mime"
	"os"
	"path/filepath"
	"strings"
)

func newID() (string, error) {
	value := make([]byte, 8)
	if _, err := rand.Read(value); err != nil {
		return "", fmt.Errorf("create file ID: %w", err)
	}
	return hex.EncodeToString(value), nil
}

func validID(id string) bool {
	decoded, err := hex.DecodeString(id)
	return err == nil && len(decoded) == 8
}

func safeName(name string) string {
	name = filepath.Base(strings.ReplaceAll(name, "\\", "/"))
	name = strings.ReplaceAll(strings.TrimSpace(name), "--", "-")
	if name == "" || name == "." {
		return "file"
	}
	return name
}

func splitStoredName(stored string) (string, string, bool) {
	parts := strings.SplitN(stored, "--", 2)
	return parts[0], parts[len(parts)-1], len(parts) == 2 && validID(parts[0])
}

func fileFrom(id, name string, size int64, info os.FileInfo) File {
	contentType := mime.TypeByExtension(filepath.Ext(name))
	if contentType == "" {
		contentType = "application/octet-stream"
	}
	return File{
		ID:          id,
		Name:        name,
		ContentType: contentType,
		Size:        size,
		UploadedAt:  info.ModTime().UTC(),
	}
}

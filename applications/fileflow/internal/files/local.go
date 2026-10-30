package files

import (
	"context"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"sort"
)

// LocalStore saves each upload as: <random-id>--<original-name>.
type LocalStore struct {
	dir string
}

func NewLocalStore(dir string) (*LocalStore, error) {
	if err := os.MkdirAll(dir, 0o750); err != nil {
		return nil, fmt.Errorf("create storage directory: %w", err)
	}
	return &LocalStore{dir: dir}, nil
}

func (s *LocalStore) Save(ctx context.Context, name string, content io.Reader) (File, error) {
	if err := ctx.Err(); err != nil {
		return File{}, err
	}

	id, err := newID()
	if err != nil {
		return File{}, err
	}

	name = safeName(name)
	path := filepath.Join(s.dir, id+"--"+name)
	destination, err := os.Create(path)
	if err != nil {
		return File{}, fmt.Errorf("create file: %w", err)
	}

	size, copyErr := io.Copy(destination, content)
	closeErr := destination.Close()
	if copyErr != nil {
		_ = os.Remove(path)
		return File{}, fmt.Errorf("save file: %w", copyErr)
	}
	if closeErr != nil {
		_ = os.Remove(path)
		return File{}, fmt.Errorf("close file: %w", closeErr)
	}

	info, err := os.Stat(path)
	if err != nil {
		return File{}, fmt.Errorf("read saved file: %w", err)
	}
	return fileFrom(id, name, size, info), nil
}

func (s *LocalStore) List(ctx context.Context) ([]File, error) {
	entries, err := os.ReadDir(s.dir)
	if err != nil {
		return nil, fmt.Errorf("list files: %w", err)
	}

	result := make([]File, 0, len(entries))
	for _, entry := range entries {
		if err := ctx.Err(); err != nil {
			return nil, err
		}
		id, name, ok := splitStoredName(entry.Name())
		if entry.IsDir() || !ok {
			continue
		}
		info, err := entry.Info()
		if err != nil {
			return nil, fmt.Errorf("read file info: %w", err)
		}
		result = append(result, fileFrom(id, name, info.Size(), info))
	}

	sort.Slice(result, func(i, j int) bool {
		return result[i].UploadedAt.After(result[j].UploadedAt)
	})
	return result, nil
}

func (s *LocalStore) Open(ctx context.Context, id string) (OpenedFile, error) {
	path, name, err := s.find(id)
	if err != nil {
		return OpenedFile{}, err
	}
	if err := ctx.Err(); err != nil {
		return OpenedFile{}, err
	}

	content, err := os.Open(path)
	if err != nil {
		return OpenedFile{}, fmt.Errorf("open file: %w", err)
	}
	info, err := content.Stat()
	if err != nil {
		_ = content.Close()
		return OpenedFile{}, fmt.Errorf("read file info: %w", err)
	}
	return OpenedFile{File: fileFrom(id, name, info.Size(), info), Content: content}, nil
}

func (s *LocalStore) Delete(ctx context.Context, id string) error {
	path, _, err := s.find(id)
	if err != nil {
		return err
	}
	if err := ctx.Err(); err != nil {
		return err
	}
	if err := os.Remove(path); err != nil {
		return fmt.Errorf("delete file: %w", err)
	}
	return nil
}

func (s *LocalStore) find(id string) (string, string, error) {
	if !validID(id) {
		return "", "", ErrNotFound
	}
	matches, err := filepath.Glob(filepath.Join(s.dir, id+"--*"))
	if err != nil || len(matches) != 1 {
		return "", "", ErrNotFound
	}
	_, name, ok := splitStoredName(filepath.Base(matches[0]))
	if !ok {
		return "", "", ErrNotFound
	}
	return matches[0], name, nil
}

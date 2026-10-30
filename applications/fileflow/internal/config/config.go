package config

import (
	"os"
	"strconv"
)

const defaultMaxUploadBytes int64 = 20 << 20

type Config struct {
	Port           string
	StorageDir     string
	MaxUploadBytes int64
}

func Load() Config {
	return Config{
		Port:           env("PORT", "8080"),
		StorageDir:     env("STORAGE_DIR", "/data"),
		MaxUploadBytes: envInt("MAX_UPLOAD_BYTES", defaultMaxUploadBytes),
	}
}

func env(name, fallback string) string {
	if value := os.Getenv(name); value != "" {
		return value
	}
	return fallback
}

func envInt(name string, fallback int64) int64 {
	value, err := strconv.ParseInt(os.Getenv(name), 10, 64)
	if err != nil || value <= 0 {
		return fallback
	}
	return value
}

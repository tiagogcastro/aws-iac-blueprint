package config

import (
	"os"
	"strconv"
)

const defaultMaxUploadBytes int64 = 20 << 20

type Config struct {
	Port           string
	MaxUploadBytes int64
	AWSRegion      string
	AWSEndpoint    string
	S3Bucket       string
	FilesTable     string
	EventsTable    string
	QueueURL       string
	OwnerID        string
}

func Load() Config {
	return Config{
		Port:           env("PORT", "8080"),
		MaxUploadBytes: envInt("MAX_UPLOAD_BYTES", defaultMaxUploadBytes),
		AWSRegion:      env("AWS_REGION", "us-east-1"),
		AWSEndpoint:    os.Getenv("AWS_ENDPOINT_URL"),
		S3Bucket:       mustEnv("S3_BUCKET"),
		FilesTable:     mustEnv("DYNAMODB_FILES_TABLE"),
		EventsTable:    mustEnv("DYNAMODB_EVENTS_TABLE"),
		QueueURL:       mustEnv("SQS_QUEUE_URL"),
		OwnerID:        env("FILEFLOW_OWNER_ID", "public"),
	}
}

func mustEnv(name string) string {
	value := os.Getenv(name)
	if value == "" {
		panic("missing required environment variable: " + name)
	}
	return value
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

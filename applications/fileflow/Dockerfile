FROM golang:1.27-alpine AS build

WORKDIR /src
COPY go.mod ./
COPY cmd ./cmd
COPY internal ./internal
COPY webui ./webui
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/fileflow ./cmd/fileflow

FROM alpine:3.22

RUN addgroup -S -g 10001 fileflow \
    && adduser -S -D -H -u 10001 -G fileflow fileflow \
    && mkdir -p /data \
    && chown fileflow:fileflow /data

COPY --from=build /out/fileflow /usr/local/bin/fileflow

USER 10001:10001
EXPOSE 8080
VOLUME ["/data"]
ENV PORT=8080 STORAGE_DIR=/data MAX_UPLOAD_BYTES=20971520
HEALTHCHECK --interval=10s --timeout=3s --start-period=3s --retries=3 \
  CMD wget -q -O - http://127.0.0.1:8080/healthz || exit 1

ENTRYPOINT ["/usr/local/bin/fileflow"]

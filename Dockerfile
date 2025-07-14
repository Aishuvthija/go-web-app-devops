# Stage 1: Build the Go binary
FROM golang:1.22.5 AS builder

WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY . .

# ✅ Static build for distroless
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main .

# Stage 2: Distroless minimal image
FROM gcr.io/distroless/static:nonroot

WORKDIR /app

# Copy static binary and assets
COPY --from=builder /app/main .
COPY --from=builder /app/static ./static

# Expose port
EXPOSE 8080

# ✅ Use ENTRYPOINT for clearer container behavior
USER nonroot
ENTRYPOINT ["./main"]

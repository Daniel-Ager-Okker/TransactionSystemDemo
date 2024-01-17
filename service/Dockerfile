# File for automatic building of the GOLANG part

# Import base image
FROM golang:latest as builder

# Set working dir of the whole application
# Path for Linux (!) is /TransactionSystemApp
WORKDIR /TransactionSystemApp

# Set your own ENV values (DATABASE_HOST_NAME --> see IPv4 in ipconfig)
ENV DATABASE_HOST_NAME=172.25.32.1
ENV DATABASE_USER=postgres
ENV DATABASE_PASSWORD=postgres
ENV DATABASE_NAME=postgres
ENV DATABASE_PORT=5432
ENV SSL_MODE=disable

# Build application in the gloang container
COPY service/app ./app
COPY service/backend ./backend
COPY service/frontend ./frontend
COPY service/go.mod ./
COPY service/go.sum ./
RUN go mod download
RUN go build ./app/main.go
RUN go install -v golang.org/x/tools/gopls@latest
RUN go install -v github.com/go-delve/delve/cmd/dlv@latest

# CMD ["./main"]

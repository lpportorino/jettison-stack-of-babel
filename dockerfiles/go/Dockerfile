# Go Container - Go development tools
ARG BASE_IMAGE=ghcr.io/lpportorino/jon-babylon-base:latest
FROM ${BASE_IMAGE}

# Switch to root for installation
USER root

# Install Go
COPY dockerfiles/go/tools /tmp/tools

RUN chmod +x /tmp/tools/**/*.sh && \
    /tmp/tools/golang/install.sh && \
    rm -rf /tmp/tools

# Setup environment
ENV GOROOT="/usr/local/go"
ENV GOPATH="/opt/go"
ENV PATH="/usr/local/go/bin:/opt/go/bin:${PATH}"

# Create Go workspace directories with permissive permissions
RUN mkdir -p /tmp/go/{bin,src,pkg} && \
    chmod -R 777 /tmp/go && \
    mkdir -p /opt/go/{bin,src,pkg} && \
    chmod -R 777 /opt/go

# Install Go tools
RUN export GOPATH=/opt/go && \
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest && \
    go install github.com/go-task/task/v3/cmd/task@latest && \
    go install github.com/air-verse/air@latest && \
    go install golang.org/x/tools/gopls@latest && \
    go install golang.org/x/tools/cmd/goimports@latest && \
    go install github.com/go-delve/delve/cmd/dlv@latest

# Fix permissions for any user - world-writable for CI environments
RUN chmod -R 777 /opt/go && \
    # Make go module cache accessible
    mkdir -p /tmp/go-cache && chmod 777 /tmp/go-cache

# Pre-populate module cache with common Jettison dependencies
# This enables golangci-lint to work without downloading modules
# NOTE: Must use /opt/cache-warmer (not /tmp) - Go refuses to work in /tmp
RUN mkdir -p /opt/cache-warmer && \
    cd /opt/cache-warmer && \
    echo 'module cache-warmer' > go.mod && \
    echo 'go 1.23' >> go.mod && \
    echo '' >> go.mod && \
    echo 'require (' >> go.mod && \
    echo '  golang.org/x/crypto v0.31.0' >> go.mod && \
    echo '  github.com/redis/go-redis/v9 v9.7.0' >> go.mod && \
    echo '  github.com/jackc/pgx/v4 v4.18.3' >> go.mod && \
    echo '  github.com/google/go-containerregistry v0.20.2' >> go.mod && \
    echo ')' >> go.mod && \
    GOPATH=/opt/go go mod download && \
    cd / && rm -rf /opt/cache-warmer

# Clean up (but keep module cache!)
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache && \
    go clean -cache
    # NOTE: Removed "go clean -modcache" to preserve downloaded modules

# Switch back to developer
USER developer
WORKDIR /workspace

# Verify installations
RUN go version && \
    golangci-lint --version && \
    task --version && \
    air -v

CMD ["/bin/bash"]
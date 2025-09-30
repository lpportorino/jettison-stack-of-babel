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
ENV GOPATH="/home/developer/go"
ENV PATH="/usr/local/go/bin:/home/developer/go/bin:${PATH}"

# Create Go workspace directories
RUN mkdir -p /home/developer/go/{bin,src,pkg} && \
    chown -R developer:developer /home/developer/go

# Install Go tools
RUN export GOPATH=/home/developer/go && \
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest && \
    go install github.com/go-task/task/v3/cmd/task@latest && \
    go install github.com/cosmtrek/air@latest && \
    go install golang.org/x/tools/gopls@latest && \
    go install golang.org/x/tools/cmd/goimports@latest && \
    go install github.com/go-delve/delve/cmd/dlv@latest

# Fix permissions
RUN chown -R developer:developer /home/developer/go && \
    chmod -R 755 /home/developer/go

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache && \
    go clean -cache && \
    go clean -modcache

# Switch back to developer
USER developer
WORKDIR /workspace

# Verify installations
RUN go version && \
    golangci-lint --version && \
    task --version && \
    air -v

CMD ["/bin/bash"]
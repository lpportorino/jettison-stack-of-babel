#!/bin/bash
# Go 1.23.1 Installation Script

set -e

echo "=== Installing Go 1.25.1 ==="

GO_VERSION="1.25.1"
ARCH=$(uname -m)

# Map architecture names
if [ "$ARCH" = "x86_64" ]; then
    GO_ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
    GO_ARCH="arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

GO_TARBALL="go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
GO_URL="https://go.dev/dl/${GO_TARBALL}"

echo "Downloading Go ${GO_VERSION} for ${GO_ARCH}..."

# Install prerequisites
apt-get update
apt-get install -y wget

# Download Go
cd /tmp
wget -q "$GO_URL"

# Remove any previous Go installation
rm -rf /usr/local/go

# Extract the archive
echo "Extracting Go..."
tar -C /usr/local -xzf "$GO_TARBALL"
rm "$GO_TARBALL"

# Set up environment
cat > /etc/profile.d/go.sh << 'EOF'
export PATH=$PATH:/usr/local/go/bin
export GOPATH=/opt/go
export PATH=$PATH:$GOPATH/bin
EOF

# Export for current session
export PATH=$PATH:/usr/local/go/bin

echo "✓ Go ${GO_VERSION} installed successfully"
go version
#!/bin/bash
# Zellij Installation Script
# Terminal multiplexer with modern features

set -e

echo "=== Installing Zellij v0.41.2 ==="

# Detect architecture
ARCH=$(dpkg --print-architecture)
echo "Detected architecture: $ARCH"

# Set download URL based on architecture
if [ "$ARCH" = "arm64" ]; then
    ZELLIJ_URL="https://github.com/zellij-org/zellij/releases/download/v0.41.2/zellij-aarch64-unknown-linux-musl.tar.gz"
elif [ "$ARCH" = "amd64" ]; then
    ZELLIJ_URL="https://github.com/zellij-org/zellij/releases/download/v0.41.2/zellij-x86_64-unknown-linux-musl.tar.gz"
else
    echo "ERROR: Unsupported architecture: $ARCH"
    exit 1
fi

echo "Downloading Zellij from: $ZELLIJ_URL"

# Download and install
wget -q -O /tmp/zellij.tar.gz "$ZELLIJ_URL"
tar -xzf /tmp/zellij.tar.gz -C /usr/local/bin
chmod +x /usr/local/bin/zellij
rm /tmp/zellij.tar.gz

# Verify installation
if ! command -v zellij &> /dev/null; then
    echo "ERROR: Zellij installation failed"
    exit 1
fi

echo "✓ Zellij installed successfully"
zellij --version

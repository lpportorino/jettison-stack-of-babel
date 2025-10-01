#!/bin/bash
# FZF Installation Script
# Fuzzy finder for the command line

set -e

echo "=== Installing FZF v0.58.0 ==="

# Detect architecture
ARCH=$(dpkg --print-architecture)
echo "Detected architecture: $ARCH"

# Set download URL based on architecture
if [ "$ARCH" = "arm64" ]; then
    FZF_URL="https://github.com/junegunn/fzf/releases/download/v0.58.0/fzf-0.58.0-linux_arm64.tar.gz"
elif [ "$ARCH" = "amd64" ]; then
    FZF_URL="https://github.com/junegunn/fzf/releases/download/v0.58.0/fzf-0.58.0-linux_amd64.tar.gz"
else
    echo "ERROR: Unsupported architecture: $ARCH"
    exit 1
fi

echo "Downloading FZF from: $FZF_URL"

# Download and install
wget -q -O /tmp/fzf.tar.gz "$FZF_URL"
tar -xzf /tmp/fzf.tar.gz -C /usr/local/bin
chmod +x /usr/local/bin/fzf
rm /tmp/fzf.tar.gz

# Verify installation
if ! command -v fzf &> /dev/null; then
    echo "ERROR: FZF installation failed"
    exit 1
fi

echo "✓ FZF installed successfully"
fzf --version

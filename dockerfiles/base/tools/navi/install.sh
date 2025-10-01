#!/bin/bash
# Navi Installation Script
# Interactive cheatsheet tool

set -e

echo "=== Installing Navi v2.24.0 ==="

# Detect architecture
ARCH=$(dpkg --print-architecture)
echo "Detected architecture: $ARCH"

# Set download URL based on architecture
if [ "$ARCH" = "arm64" ]; then
    NAVI_URL="https://github.com/denisidoro/navi/releases/download/v2.24.0/navi-v2.24.0-aarch64-unknown-linux-gnu.tar.gz"
elif [ "$ARCH" = "amd64" ]; then
    NAVI_URL="https://github.com/denisidoro/navi/releases/download/v2.24.0/navi-v2.24.0-x86_64-unknown-linux-musl.tar.gz"
else
    echo "ERROR: Unsupported architecture: $ARCH"
    exit 1
fi

echo "Downloading Navi from: $NAVI_URL"

# Download and install
wget -q -O /tmp/navi.tar.gz "$NAVI_URL"
tar -xzf /tmp/navi.tar.gz -C /usr/local/bin
chmod +x /usr/local/bin/navi
rm /tmp/navi.tar.gz

# Verify installation
if ! command -v navi &> /dev/null; then
    echo "ERROR: Navi installation failed"
    exit 1
fi

echo "✓ Navi installed successfully"
navi --version

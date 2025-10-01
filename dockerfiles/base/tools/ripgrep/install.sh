#!/bin/bash
# Ripgrep Installation Script
# Fast recursive search tool

set -e

echo "=== Installing Ripgrep v14.1.1 ==="

# Detect architecture
ARCH=$(dpkg --print-architecture)
echo "Detected architecture: $ARCH"

# Set download URL based on architecture
if [ "$ARCH" = "arm64" ]; then
    RG_URL="https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-aarch64-unknown-linux-gnu.tar.gz"
elif [ "$ARCH" = "amd64" ]; then
    RG_URL="https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz"
else
    echo "ERROR: Unsupported architecture: $ARCH"
    exit 1
fi

echo "Downloading Ripgrep from: $RG_URL"

# Download and install
wget -q -O /tmp/ripgrep.tar.gz "$RG_URL"
mkdir -p /tmp/ripgrep
tar -xzf /tmp/ripgrep.tar.gz -C /tmp/ripgrep --strip-components=1

# Install binary
cp /tmp/ripgrep/rg /usr/local/bin/
chmod +x /usr/local/bin/rg

# Install man page if available
if [ -f /tmp/ripgrep/doc/rg.1 ]; then
    mkdir -p /usr/local/share/man/man1
    cp /tmp/ripgrep/doc/rg.1 /usr/local/share/man/man1/
fi

# Install shell completions if available
if [ -f /tmp/ripgrep/complete/rg.bash ]; then
    mkdir -p /usr/local/share/bash-completion/completions
    cp /tmp/ripgrep/complete/rg.bash /usr/local/share/bash-completion/completions/rg
fi

# Clean up
rm -rf /tmp/ripgrep.tar.gz /tmp/ripgrep

# Verify installation
if ! command -v rg &> /dev/null; then
    echo "ERROR: Ripgrep installation failed"
    exit 1
fi

echo "✓ Ripgrep installed successfully"
rg --version

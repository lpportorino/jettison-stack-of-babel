#!/bin/bash
# Neovim Installation Script
# Installs latest Neovim (required for NvChad which needs 0.11+)

set -e

echo "=== Installing Neovim (latest stable) ==="

# Detect architecture
ARCH=$(dpkg --print-architecture)
echo "Detected architecture: $ARCH"

# Ubuntu 22.04 has neovim 0.6.1, but NvChad requires 0.11+
# We'll install from GitHub releases

NVIM_VERSION="v0.11.0"
echo "Installing Neovim ${NVIM_VERSION}..."

if [ "$ARCH" = "arm64" ]; then
    NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-arm64.tar.gz"
elif [ "$ARCH" = "amd64" ]; then
    NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"
else
    echo "ERROR: Unsupported architecture: $ARCH"
    exit 1
fi

echo "Downloading Neovim from: $NVIM_URL"

# Download and extract
wget -q -O /tmp/nvim.tar.gz "$NVIM_URL"
tar -xzf /tmp/nvim.tar.gz -C /tmp

# Remove old neovim if installed via apt
if dpkg -l | grep -q neovim; then
    apt-get remove -y neovim
fi

# Install to /usr/local
cp -r /tmp/nvim-linux-*/bin/* /usr/local/bin/
cp -r /tmp/nvim-linux-*/lib/* /usr/local/lib/
cp -r /tmp/nvim-linux-*/share/* /usr/local/share/

# Clean up
rm -rf /tmp/nvim.tar.gz /tmp/nvim-linux-*

# Verify installation
if ! command -v nvim &> /dev/null; then
    echo "ERROR: Neovim installation failed"
    exit 1
fi

echo "✓ Neovim installed successfully"
nvim --version | head -n 1

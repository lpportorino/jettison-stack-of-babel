#!/bin/bash
# Nuitka Python Compiler Installation

set -e

echo "=== Installing Nuitka Python Compiler ==="

# Ensure Python is installed
if ! command -v python3 &> /dev/null; then
    echo "✗ Python3 not found. Please install Python first."
    exit 1
fi

# Install Nuitka and dependencies
pip3 install --upgrade nuitka ordered-set

# Install patchelf for Linux binary manipulation
apt-get update
apt-get install -y patchelf ccache

# Create Nuitka cache directory
mkdir -p /opt/nuitka-cache
export NUITKA_CACHE_DIR="/opt/nuitka-cache"

# Add Nuitka configuration
cat > /etc/profile.d/nuitka.sh << 'EOF'
export NUITKA_CACHE_DIR="/opt/nuitka-cache"
alias nuitka='python3 -m nuitka'
EOF

echo "✓ Nuitka installed successfully"
python3 -m nuitka --version
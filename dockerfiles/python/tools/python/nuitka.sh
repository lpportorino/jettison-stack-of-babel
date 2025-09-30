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

# Add Nuitka configuration to use Clang
cat > /etc/profile.d/nuitka.sh << 'EOF'
export NUITKA_CACHE_DIR="/opt/nuitka-cache"
export CC="clang"
export CXX="clang++"
alias nuitka='python3 -m nuitka'
alias nuitka-clang='python3 -m nuitka --clang'
EOF

echo "✓ Nuitka installed successfully (configured to use Clang)"
echo "Nuitka version:"
python3 -m nuitka --version
echo "Configured compiler: clang"
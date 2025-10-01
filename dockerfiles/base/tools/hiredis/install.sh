#!/bin/bash
# Hiredis Installation Script
# Redis C client library built from source

set -e

echo "=== Building and Installing Hiredis v1.3.0 ==="

# Detect architecture
ARCH=$(dpkg --print-architecture)
echo "Detected architecture: $ARCH"

# Install prerequisites
apt-get update
apt-get install -y git build-essential libssl-dev

# Clone source
HIREDIS_VERSION="1.3.0"
echo "Cloning hiredis v${HIREDIS_VERSION}..."
git clone --depth 1 --branch "v${HIREDIS_VERSION}" https://github.com/redis/hiredis.git /tmp/hiredis

cd /tmp/hiredis

# Set optimization flags based on architecture
if [ "$ARCH" = "arm64" ]; then
    export CFLAGS="-march=armv8.2-a+crypto+fp16+rcpc+dotprod -mtune=cortex-a78 -O3 -fPIC"
    export CXXFLAGS="-march=armv8.2-a+crypto+fp16+rcpc+dotprod -mtune=cortex-a78 -O3 -fPIC"
    echo "Using ARM64 optimizations for Cortex-A78"
else
    export CFLAGS="-O3 -fPIC"
    export CXXFLAGS="-O3 -fPIC"
    echo "Using generic optimizations"
fi

# Build and install
echo "Building hiredis..."
make -j$(nproc) PREFIX=/usr/local

echo "Installing hiredis..."
make install PREFIX=/usr/local

# Update library cache
ldconfig

# Clean up
cd /
rm -rf /tmp/hiredis

# Verify installation
if ! pkg-config --exists hiredis; then
    echo "WARNING: hiredis pkg-config not found, but library should be installed"
fi

echo "✓ Hiredis built and installed successfully"
echo "Installed version: ${HIREDIS_VERSION}"

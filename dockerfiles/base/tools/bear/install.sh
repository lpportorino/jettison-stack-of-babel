#!/bin/bash
# Bear Installation Script
# Compilation database generator for C/C++ projects

set -e

echo "=== Building and Installing Bear v3.1.6 ==="

# Detect architecture
ARCH=$(dpkg --print-architecture)
echo "Detected architecture: $ARCH"

# Install prerequisites
apt-get update
apt-get install -y \
    wget \
    build-essential \
    cmake \
    protobuf-compiler \
    protobuf-compiler-grpc \
    libgrpc++-dev \
    libfmt-dev \
    libspdlog-dev \
    nlohmann-json3-dev

# Download source
BEAR_VERSION="3.1.6"
echo "Downloading Bear v${BEAR_VERSION}..."
wget -q -O /tmp/bear.tar.gz "https://github.com/rizsotto/Bear/archive/refs/tags/${BEAR_VERSION}.tar.gz"

# Extract source
echo "Extracting source..."
mkdir -p /tmp/bear-build
tar -xzf /tmp/bear.tar.gz -C /tmp/bear-build --strip-components=1

cd /tmp/bear-build
mkdir -p build
cd build

# Configure with CMake
echo "Configuring build..."
if [ "$ARCH" = "arm64" ]; then
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DENABLE_UNIT_TESTS=OFF \
        -DENABLE_FUNC_TESTS=OFF \
        -DCMAKE_C_FLAGS="-march=armv8.2-a+crypto+fp16+rcpc+dotprod -mtune=cortex-a78" \
        -DCMAKE_CXX_FLAGS="-march=armv8.2-a+crypto+fp16+rcpc+dotprod -mtune=cortex-a78"
    echo "Using ARM64 optimizations for Cortex-A78"
else
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DENABLE_UNIT_TESTS=OFF \
        -DENABLE_FUNC_TESTS=OFF
    echo "Using generic optimizations"
fi

# Build
echo "Building Bear (this may take a few minutes)..."
make -j$(nproc)

# Install
echo "Installing Bear..."
make install

# Clean up
cd /
rm -rf /tmp/bear.tar.gz /tmp/bear-build

# Verify installation
if ! command -v bear &> /dev/null; then
    echo "ERROR: Bear installation failed"
    exit 1
fi

echo "✓ Bear built and installed successfully"
bear --version

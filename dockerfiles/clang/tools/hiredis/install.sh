#!/bin/bash
# Hiredis Build Script for Clang Container
# Builds hiredis for both AMD64 (native) and ARM64 (cross-compilation)
# Uses Clang 21 for optimal code generation

set -e

HIREDIS_VERSION="1.3.0"

echo "=== Building Hiredis v${HIREDIS_VERSION} with Clang 21 ==="

# Clone source
echo "Cloning hiredis v${HIREDIS_VERSION}..."
git clone --depth 1 --branch "v${HIREDIS_VERSION}" https://github.com/redis/hiredis.git /tmp/hiredis-build

# ============================================================================
# Build 1: AMD64 Native (optimized for host)
# ============================================================================
echo ""
echo "=== Building AMD64 Native Version ==="

cd /tmp/hiredis-build

# Clean any previous builds
make clean || true

# Use Clang 21 with -O3 optimizations
export CC=clang
export AR=llvm-ar
export CFLAGS="-O3 -fPIC"

echo "Building hiredis for AMD64..."
make -j$(nproc) PREFIX=/usr/local

echo "Installing AMD64 hiredis..."
make install PREFIX=/usr/local

# Update library cache
ldconfig

echo "✓ AMD64 build installed to /usr/local"

# ============================================================================
# Build 2: ARM64 Cross-Compilation (Cortex-A78AE optimized for NVIDIA Orin)
# ============================================================================
echo ""
echo "=== Building ARM64 Cross-Compiled Version ==="

# Clean for ARM64 build
make clean

# Clang cross-compilation for ARM64 with full Cortex-A78AE optimizations
export CC=clang
export AR=llvm-ar
export CFLAGS="--target=aarch64-linux-gnu \
-march=armv8.2-a+crypto+fp16+rcpc+dotprod+lse \
-mtune=cortex-a78ae \
-O3 \
-fPIC"

echo "Building hiredis for ARM64 (Cortex-A78AE with all extensions)..."
echo "  Target: NVIDIA Jetson AGX Orin"
echo "  Extensions: crypto, fp16, rcpc, dotprod, lse"
echo "  Note: Building static library only (shared library requires complex cross-linking)"

# Build only static library for ARM64 (shared library is difficult to cross-compile)
make -j$(nproc) libhiredis.a \
    PREFIX=/usr/aarch64-linux-gnu \
    CC="${CC}" \
    AR="${AR}" \
    CFLAGS="${CFLAGS}"

echo "Installing ARM64 hiredis (static library and headers)..."
# Manually install static library and headers (skip shared library)
mkdir -p /usr/aarch64-linux-gnu/include/hiredis /usr/aarch64-linux-gnu/include/hiredis/adapters /usr/aarch64-linux-gnu/lib
cp -pPR hiredis.h async.h read.h sds.h alloc.h sockcompat.h /usr/aarch64-linux-gnu/include/hiredis
cp -pPR adapters/*.h /usr/aarch64-linux-gnu/include/hiredis/adapters
cp -pPR libhiredis.a /usr/aarch64-linux-gnu/lib

# Create pkg-config file for ARM64
mkdir -p /usr/lib/aarch64-linux-gnu/pkgconfig
cat > /usr/lib/aarch64-linux-gnu/pkgconfig/hiredis.pc <<EOF
prefix=/usr/aarch64-linux-gnu
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: hiredis
Description: Minimalistic C client library for Redis (ARM64)
Version: ${HIREDIS_VERSION}
Libs: -L\${libdir} -lhiredis
Cflags: -I\${includedir}
EOF

echo "✓ ARM64 build installed to /usr/aarch64-linux-gnu"

# ============================================================================
# Verification
# ============================================================================
echo ""
echo "=== Verifying Installations ==="

# Verify AMD64
if [ ! -f /usr/local/lib/libhiredis.a ]; then
    echo "ERROR: AMD64 static library not found"
    exit 1
fi

if [ ! -f /usr/local/include/hiredis/hiredis.h ]; then
    echo "ERROR: AMD64 headers not found"
    exit 1
fi

# Verify ARM64
if [ ! -f /usr/aarch64-linux-gnu/lib/libhiredis.a ]; then
    echo "ERROR: ARM64 static library not found"
    exit 1
fi

if [ ! -f /usr/aarch64-linux-gnu/include/hiredis/hiredis.h ]; then
    echo "ERROR: ARM64 headers not found"
    exit 1
fi

# Clean up
cd /
rm -rf /tmp/hiredis-build

echo ""
echo "✓✓✓ Hiredis build complete ✓✓✓"
echo ""
echo "AMD64 Native:"
echo "  Compiler: Clang 21"
echo "  Library:  /usr/local/lib/libhiredis.a"
echo "  Headers:  /usr/local/include/hiredis/"
echo ""
echo "ARM64 Cross-Compiled:"
echo "  Compiler: Clang 21"
echo "  Target:   NVIDIA Jetson AGX Orin (Cortex-A78AE)"
echo "  Arch:     ARMv8.2-A+crypto+fp16+rcpc+dotprod+lse"
echo "  Library:  /usr/aarch64-linux-gnu/lib/libhiredis.a"
echo "  Headers:  /usr/aarch64-linux-gnu/include/hiredis/"
echo ""

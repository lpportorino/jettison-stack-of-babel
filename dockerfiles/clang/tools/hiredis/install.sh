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

# Use LLD (LLVM linker) for ARM64 shared library linking
export LDFLAGS="--target=aarch64-linux-gnu \
-fuse-ld=lld \
-L/usr/aarch64-linux-gnu/lib"

echo "Building hiredis for ARM64 (Cortex-A78AE with all extensions)..."
echo "  Target: NVIDIA Jetson AGX Orin"
echo "  Extensions: crypto, fp16, rcpc, dotprod, lse"
echo "  Linker: LLD (LLVM linker)"
echo "  Building: Static AND Shared libraries"

# Build both static and shared libraries using LLD linker
make -j$(nproc) \
    PREFIX=/usr/aarch64-linux-gnu \
    CC="${CC}" \
    AR="${AR}" \
    LDFLAGS="${LDFLAGS}" \
    CFLAGS="${CFLAGS}"

echo "Installing ARM64 hiredis..."
make install PREFIX=/usr/aarch64-linux-gnu

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

if [ ! -f /usr/aarch64-linux-gnu/lib/libhiredis.so ]; then
    echo "ERROR: ARM64 shared library not found"
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
echo "  Static:   /usr/local/lib/libhiredis.a"
echo "  Shared:   /usr/local/lib/libhiredis.so"
echo "  Headers:  /usr/local/include/hiredis/"
echo ""
echo "ARM64 Cross-Compiled:"
echo "  Compiler: Clang 21"
echo "  Linker:   LLD (LLVM linker)"
echo "  Target:   NVIDIA Jetson AGX Orin (Cortex-A78AE)"
echo "  Arch:     ARMv8.2-A+crypto+fp16+rcpc+dotprod+lse"
echo "  Static:   /usr/aarch64-linux-gnu/lib/libhiredis.a"
echo "  Shared:   /usr/aarch64-linux-gnu/lib/libhiredis.so"
echo "  Headers:  /usr/aarch64-linux-gnu/include/hiredis/"
echo ""

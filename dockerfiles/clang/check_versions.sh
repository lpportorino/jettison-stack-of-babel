#!/bin/bash
# Clang container version check
set -e

echo "=== Clang Container Version Check ==="
echo ""
echo "Clang: $(clang --version | head -n1)"
echo "Clang++: $(clang++ --version | head -n1)"
echo "clang-format: $(clang-format --version)"
echo "clang-tidy: $(clang-tidy --version 2>&1 | head -n1)"
echo "CMake: $(cmake --version | head -n1)"
echo "Make: $(make --version | head -n1)"
echo "Ninja: $(ninja --version)"
echo ""
echo "CC: $CC"
echo "CXX: $CXX"
echo ""

# Check hiredis (built from source with Clang 21)
echo "=== Hiredis Library ==="
if pkg-config --exists hiredis 2>/dev/null; then
    echo "✓ Hiredis (AMD64): $(pkg-config --modversion hiredis)"
else
    echo "⚠ Hiredis (AMD64): pkg-config not found (may be installed without .pc file)"
fi

if [ -f /usr/local/lib/libhiredis.a ]; then
    echo "✓ Hiredis static library (AMD64): /usr/local/lib/libhiredis.a"
else
    echo "✗ Hiredis static library (AMD64) not found"
    exit 1
fi

if [ -f /usr/aarch64-linux-gnu/lib/libhiredis.a ]; then
    echo "✓ Hiredis static library (ARM64): /usr/aarch64-linux-gnu/lib/libhiredis.a"
else
    echo "✗ Hiredis static library (ARM64) not found"
    exit 1
fi
echo ""

echo "✓ Clang container ready"
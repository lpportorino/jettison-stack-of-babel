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
echo "✓ Clang container ready"
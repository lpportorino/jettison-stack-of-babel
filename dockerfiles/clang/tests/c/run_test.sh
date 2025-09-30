#!/bin/bash
set -e

# Ensure we're in the right directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

echo "=== Testing C compilation and tools ==="

# Test Clang version
echo "Clang version:"
clang --version

# Compile the test program
echo ""
echo "Compiling C test program..."
clang -o test test.c

# Run the test program
echo "Running C test program..."
./test

# Test clang-format
echo ""
echo "Testing clang-format..."
clang-format --version

# Check formatting (dry-run)
echo "Checking C code formatting..."
clang-format --dry-run --Werror test.c || echo "Format check completed (may have formatting differences)"

# Test clang-tidy
echo ""
echo "Testing clang-tidy..."
clang-tidy --version

# Run clang-tidy analysis
echo "Running clang-tidy static analysis..."
clang-tidy test.c -- -I/usr/include || echo "clang-tidy analysis completed (may have warnings)"

# Test compilation with optimization flags
echo ""
echo "Testing optimized compilation..."
clang -O3 -Wall -Wextra -o test_opt test.c
./test_opt

# Test compilation with sanitizers
echo ""
echo "Testing with AddressSanitizer..."
clang -fsanitize=address -g -o test_asan test.c
ASAN_OPTIONS=detect_leaks=0 ./test_asan

# Clean up
rm -f test test_opt test_asan

echo ""
echo "✓ C tests completed!"
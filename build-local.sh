#!/bin/bash
# Build all containers locally in the correct order

set -e

echo "Building containers locally..."
echo ""

# Build base first (required by all)
echo "==> Building base container..."
docker-compose build base

# Build clang (depends on base)
echo "==> Building clang container..."
docker-compose build clang

# Build containers that depend on base
echo "==> Building jvm, rust, go, web containers..."
docker-compose build jvm rust go web

# Build python (depends on clang)
echo "==> Building python container..."
docker-compose build python

echo ""
echo "✅ All containers built successfully!"
echo ""
echo "Available images:"
docker images | grep "jon-babylon"

#!/bin/bash
# Build all containers locally in the correct order

set -e

echo "Building containers locally..."
echo ""

# Build base first (required by all)
echo "==> Building base container..."
docker build -t jon-babylon-base:latest -f dockerfiles/base/Dockerfile .

# Build clang (depends on base)
echo "==> Building clang container..."
docker build -t jon-babylon-clang:latest \
  --build-arg BASE_IMAGE=jon-babylon-base:latest \
  -f dockerfiles/clang/Dockerfile .

# Build containers that depend on base
echo "==> Building jvm container..."
docker build -t jon-babylon-jvm:latest \
  --build-arg BASE_IMAGE=jon-babylon-base:latest \
  -f dockerfiles/jvm/Dockerfile .

echo "==> Building rust container..."
docker build -t jon-babylon-rust:latest \
  --build-arg BASE_IMAGE=jon-babylon-base:latest \
  -f dockerfiles/rust/Dockerfile .

echo "==> Building go container..."
docker build -t jon-babylon-go:latest \
  --build-arg BASE_IMAGE=jon-babylon-base:latest \
  -f dockerfiles/go/Dockerfile .

echo "==> Building web container..."
docker build -t jon-babylon-web:latest \
  --build-arg BASE_IMAGE=jon-babylon-base:latest \
  -f dockerfiles/web/Dockerfile .

# Build python (depends on clang)
echo "==> Building python container..."
docker build -t jon-babylon-python:latest \
  --build-arg CLANG_IMAGE=jon-babylon-clang:latest \
  -f dockerfiles/python/Dockerfile .

echo ""
echo "✅ All containers built successfully!"
echo ""
echo "Available images:"
docker images | grep "jon-babylon"

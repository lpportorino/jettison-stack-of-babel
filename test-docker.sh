#!/bin/bash
# Quick Docker build test

echo "Testing Docker build stages..."

# Test base stage
echo "1. Building base stage..."
docker build -f docker/stages/00-base.Dockerfile -t test:base . || exit 1

echo "2. Testing base image..."
docker run --rm test:base bash -c "echo 'OK: Base works' && uname -a"

echo "3. Building essentials..."
docker build --build-arg BASE_IMAGE=test:base -f docker/stages/01-build-essentials.Dockerfile -t test:essentials . || exit 1

echo "4. Testing with Python script..."
docker run --rm -v $(pwd)/tests/python:/workspace test:essentials bash -c "cd /workspace && python3 --version && python3 src/main.py" || echo "Python not yet installed"

echo "Test complete!"

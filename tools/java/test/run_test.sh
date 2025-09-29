#!/bin/bash
# Test Java installation

set -e

echo "=== Testing Java Installation ==="

cd $(dirname "$0")

# Compile Java code
echo "Compiling HelloWorld.java..."
javac HelloWorld.java

# Run Java program
echo "Running HelloWorld..."
java HelloWorld

# Clean up
rm -f HelloWorld.class

echo "✓ Java test completed successfully"
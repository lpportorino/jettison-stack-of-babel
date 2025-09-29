#!/bin/bash
# Verify OpenJDK installation

set -e

echo "=== Verifying OpenJDK Installation ==="

# Check if java command exists
if ! command -v java &> /dev/null; then
    echo "✗ Java command not found"
    exit 1
fi

# Check Java version
JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f 2)
echo "Java version: $JAVA_VERSION"

# Verify it's version 21
if [[ $JAVA_VERSION == 21* ]]; then
    echo "✓ Java 21 is installed"
else
    echo "✗ Expected Java 21, found $JAVA_VERSION"
    exit 1
fi

# Check if javac exists
if ! command -v javac &> /dev/null; then
    echo "✗ javac command not found"
    exit 1
fi

# Check JAVA_HOME
if [ -z "$JAVA_HOME" ]; then
    echo "⚠ JAVA_HOME not set"
else
    echo "✓ JAVA_HOME: $JAVA_HOME"
fi

echo "✓ OpenJDK verification complete"
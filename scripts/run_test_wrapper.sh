#!/bin/bash
# Wrapper script to fix permissions and run tests
# This ensures tests can write to the workspace directory

set -e

# Fix permissions on the workspace directory
if [ -d "/workspace" ]; then
    # Use sudo if available, otherwise try without
    if command -v sudo &> /dev/null; then
        sudo chown -R developer:developer /workspace 2>/dev/null || true
        sudo chmod -R 755 /workspace 2>/dev/null || true
    else
        chown -R developer:developer /workspace 2>/dev/null || true
        chmod -R 755 /workspace 2>/dev/null || true
    fi
fi

# Also ensure cache directories are writable
mkdir -p ~/.cache ~/.ruff_cache ~/.gradle ~/.m2 ~/.cargo 2>/dev/null || true
chmod -R 755 ~/.cache ~/.ruff_cache ~/.gradle ~/.m2 ~/.cargo 2>/dev/null || true

# Run the actual test script
cd /workspace
if [ -x "./run_test.sh" ]; then
    ./run_test.sh
else
    echo "Error: run_test.sh not found or not executable"
    exit 1
fi
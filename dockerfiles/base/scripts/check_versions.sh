#!/bin/bash
# Base container version check
set -e

echo "=== Base Container Version Check ==="
echo "Ubuntu: $(lsb_release -d | cut -f2)"
echo "Git: $(git --version)"
echo "Curl: $(curl --version | head -n1)"
echo "User: $(whoami)"
echo "Workspace: $(pwd)"
echo "✓ Base container ready"
#!/bin/bash
# Go container version check
set -e

echo "=== Go Container Version Check ==="
echo ""
echo "Go: $(go version)"
echo "golangci-lint: $(golangci-lint --version 2>&1 | head -n1)"
echo "Task: $(task --version)"
echo "Air: $(air -v)"
echo ""
echo "GOROOT: $GOROOT"
echo "GOPATH: $GOPATH"
echo ""
echo "Go tools installed:"
ls -1 $GOPATH/bin 2>/dev/null || echo "No tools found in GOPATH/bin"
echo ""
echo "✓ Go container ready"
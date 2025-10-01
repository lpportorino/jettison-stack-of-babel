#!/bin/bash
# Go Test Suite - Test Go development environment
# Tests: Go compiler, go mod, air watcher, popular packages

set -e

echo "=== Jon-Babylon Go Container Test Suite ==="
echo

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

TESTS_PASSED=0
TESTS_FAILED=0

# Test Go version
echo "Testing Go installation..."
go version
TESTS_PASSED=$((TESTS_PASSED + 1))
echo -e "${GREEN}✓${NC}"

# Test go mod initialization
echo "Testing go mod..."
mkdir -p test-project
cd test-project
go mod init test-module
TESTS_PASSED=$((TESTS_PASSED + 1))
echo -e "${GREEN}✓${NC}"

# Create a simple Go program
echo "Creating test program..."
cat > main.go << 'EOF'
package main

import (
    "fmt"
    "net/http"
    "runtime"
    "time"
)

func main() {
    fmt.Printf("Go Version: %s\n", runtime.Version())
    fmt.Printf("OS/Arch: %s/%s\n", runtime.GOOS, runtime.GOARCH)
    fmt.Printf("NumCPU: %d\n", runtime.NumCPU())
    fmt.Printf("Time: %s\n", time.Now().Format(time.RFC3339))

    // Test goroutines
    ch := make(chan string)
    go func() {
        ch <- "Hello from goroutine!"
    }()
    fmt.Println(<-ch)

    // Test HTTP client
    resp, err := http.Get("https://httpbin.org/status/200")
    if err == nil {
        defer resp.Body.Close()
        fmt.Printf("HTTP test: %d\n", resp.StatusCode)
    }
}
EOF

# Build the program
echo "Testing Go build..."
go build -o test-binary main.go
TESTS_PASSED=$((TESTS_PASSED + 1))
echo -e "${GREEN}✓${NC}"

# Run the program
echo "Running test binary..."
./test-binary
TESTS_PASSED=$((TESTS_PASSED + 1))
echo -e "${GREEN}✓${NC}"

# Test go fmt
echo "Testing go fmt..."
go fmt main.go
TESTS_PASSED=$((TESTS_PASSED + 1))
echo -e "${GREEN}✓${NC}"

# Test go vet
echo "Testing go vet..."
go vet main.go
TESTS_PASSED=$((TESTS_PASSED + 1))
echo -e "${GREEN}✓${NC}"

# Test air (hot reload tool)
echo "Testing air installation..."
if command -v air &> /dev/null; then
    air -v
elif [ -f "/opt/go/bin/air" ]; then
    /opt/go/bin/air -v
elif [ -f "$GOPATH/bin/air" ]; then
    $GOPATH/bin/air -v
else
    echo -e "${RED}✗ air not found${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "PATH: $PATH"
    echo "GOPATH: $GOPATH"
    ls -la /opt/go/bin/ 2>/dev/null || echo "/opt/go/bin/ not found"
    ls -la $GOPATH/bin/ 2>/dev/null || echo "$GOPATH/bin/ not found"
    exit 1
fi
TESTS_PASSED=$((TESTS_PASSED + 1))
echo -e "${GREEN}✓${NC}"

# Test popular Go packages installation
echo "Testing Go package installation (gin web framework)..."
go get -u github.com/gin-gonic/gin
TESTS_PASSED=$((TESTS_PASSED + 1))
echo -e "${GREEN}✓${NC}"

# Create a simple Gin web server
echo "Testing Gin web framework..."
cat > server.go << 'EOF'
package main

import (
    "github.com/gin-gonic/gin"
    "net/http"
)

func main() {
    r := gin.Default()
    r.GET("/ping", func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{
            "message": "pong",
        })
    })
    // Don't actually run the server in tests
    // r.Run()
}
EOF

go build server.go
TESTS_PASSED=$((TESTS_PASSED + 1))
echo -e "${GREEN}✓${NC}"

# Clean up
cd ..
rm -rf test-project

echo
echo "========================================"
echo "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo "Tests Failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
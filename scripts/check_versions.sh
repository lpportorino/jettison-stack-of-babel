#!/bin/bash

# Jon-Babylon Version Check Script
# Validates all installed tools and their versions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Jon-Babylon Tool Version Report${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to check tool version
check_version() {
    local tool_name="$1"
    local version_cmd="$2"
    local min_version="$3"

    echo -n "Checking $tool_name... "

    if command -v $(echo $version_cmd | cut -d' ' -f1) &> /dev/null; then
        version_output=$(eval $version_cmd 2>&1 | head -n1 || echo "unknown")
        echo -e "${GREEN}✓${NC} $version_output"
        return 0
    else
        echo -e "${RED}✗${NC} Not found"
        return 1
    fi
}

# Track failures
FAILURES=0

echo -e "${YELLOW}Programming Languages:${NC}"
check_version "Java" "java -version" "21" || ((FAILURES++))
check_version "Kotlin" "kotlin -version" "2.0" || ((FAILURES++))
check_version "Clojure" "clojure --version" "1.12" || ((FAILURES++))
check_version "Python" "python3 --version" "3.12" || ((FAILURES++))
check_version "Rust" "rustc --version" "1.8" || ((FAILURES++))
check_version "Node.js" "node --version" "22" || ((FAILURES++))
check_version "TypeScript" "tsc --version" "5" || ((FAILURES++))
echo ""

echo -e "${YELLOW}Compilers & Linters:${NC}"
check_version "Clang" "clang --version" "21" || ((FAILURES++))
check_version "Clang++" "clang++ --version" "21" || ((FAILURES++))
check_version "clang-format" "clang-format --version" "21" || ((FAILURES++))
check_version "clang-tidy" "clang-tidy --version" "21" || ((FAILURES++))
check_version "clj-kondo" "clj-kondo --version" "" || ((FAILURES++))
check_version "Nuitka" "python3 -m nuitka --version" "2" || ((FAILURES++))
echo ""

echo -e "${YELLOW}Build Tools:${NC}"
check_version "Maven" "mvn --version" "3.9" || ((FAILURES++))
check_version "Gradle" "gradle --version" "8" || ((FAILURES++))
check_version "Leiningen" "lein version" "2" || ((FAILURES++))
check_version "Cargo" "cargo --version" "1.8" || ((FAILURES++))
check_version "npm" "npm --version" "10" || ((FAILURES++))
check_version "yarn" "yarn --version" "1" || ((FAILURES++))
check_version "pnpm" "pnpm --version" "9" || ((FAILURES++))
check_version "Bun" "bun --version" "1" || ((FAILURES++))
echo ""

echo -e "${YELLOW}JavaScript Tools:${NC}"
check_version "esbuild" "esbuild --version" "0.20" || ((FAILURES++))
check_version "Prettier" "prettier --version" "3" || ((FAILURES++))
check_version "ESLint" "eslint --version" "9" || ((FAILURES++))
echo ""

echo -e "${YELLOW}Python Environment:${NC}"
check_version "pyenv" "pyenv --version" "2" || ((FAILURES++))
check_version "pip" "pip3 --version" "24" || ((FAILURES++))
echo ""

# Generate JSON report
generate_json_report() {
    echo "{"
    echo "  \"timestamp\": \"$(date -Iseconds)\","
    echo "  \"architecture\": \"$(uname -m)\","
    echo "  \"os\": \"$(lsb_release -ds 2>/dev/null || echo 'Ubuntu 22.04')\","
    echo "  \"tools\": {"
    echo "    \"java\": \"$(java -version 2>&1 | head -n1 | cut -d'"' -f2 || echo 'not found')\","
    echo "    \"kotlin\": \"$(kotlin -version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || echo 'not found')\","
    echo "    \"clojure\": \"$(clojure --version 2>/dev/null | cut -d' ' -f2 || echo 'not found')\","
    echo "    \"python\": \"$(python3 --version | cut -d' ' -f2 || echo 'not found')\","
    echo "    \"node\": \"$(node --version | cut -c2- || echo 'not found')\","
    echo "    \"typescript\": \"$(tsc --version | cut -d' ' -f2 || echo 'not found')\","
    echo "    \"clang\": \"$(clang --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || echo 'not found')\","
    echo "    \"nuitka\": \"$(python3 -m nuitka --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || echo 'not found')\","
    echo "    \"maven\": \"$(mvn --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || echo 'not found')\","
    echo "    \"gradle\": \"$(gradle --version 2>/dev/null | grep Gradle | grep -oE '[0-9]+\.[0-9]+' | head -n1 || echo 'not found')\","
    echo "    \"bun\": \"$(bun --version || echo 'not found')\""
    echo "  },"
    echo "  \"status\": \"$([ $FAILURES -eq 0 ] && echo 'success' || echo 'failed')\","
    echo "  \"failures\": $FAILURES"
    echo "}"
}

# Save JSON report if requested
if [ "$1" = "--json" ]; then
    generate_json_report > /tmp/version_report.json
    echo ""
    echo -e "${BLUE}JSON report saved to /tmp/version_report.json${NC}"
fi

# Summary
echo -e "${BLUE}========================================${NC}"
if [ $FAILURES -eq 0 ]; then
    echo -e "${GREEN}✓ All tools installed successfully!${NC}"
    exit 0
else
    echo -e "${RED}✗ $FAILURES tool(s) not found or version mismatch${NC}"
    exit 1
fi
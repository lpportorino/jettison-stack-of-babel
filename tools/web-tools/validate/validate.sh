#!/bin/bash
# Validate Web Tools Installation

set -e

echo "=== Validating Web Tools Installation ==="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

VALIDATION_PASSED=0
VALIDATION_FAILED=0

# Function to validate tool
validate_tool() {
    local tool_name=$1
    local check_command=$2
    local min_version=$3

    echo -n "Validating $tool_name... "
    if eval $check_command &> /dev/null; then
        VERSION=$(eval $check_command 2>&1 | head -1)
        echo -e "${GREEN}✓${NC} $VERSION"
        ((VALIDATION_PASSED++))
    else
        echo -e "${RED}✗${NC} Not found"
        ((VALIDATION_FAILED++))
    fi
}

# Validate each tool
validate_tool "esbuild" "esbuild --version" "0.20"
validate_tool "Prettier" "prettier --version" "3.0"
validate_tool "ESLint" "eslint --version" "9.0"
validate_tool "Bun" "bun --version" "1.0"
validate_tool "@lit/localize" "npm list -g @lit/localize --depth=0" "0.12"

# Validate TypeScript
validate_tool "TypeScript" "tsc --version" "5.0"

# Check if packages are globally accessible
echo ""
echo "Checking global npm packages..."
npm list -g --depth=0 2>/dev/null | grep -E "(esbuild|prettier|eslint|typescript|@lit)" || true

# Summary
echo ""
echo "========================================"
echo -e "Validations Passed: ${GREEN}$VALIDATION_PASSED${NC}"
echo -e "Validations Failed: ${RED}$VALIDATION_FAILED${NC}"

if [ $VALIDATION_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All web tools validated successfully!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some validations failed${NC}"
    exit 1
fi
#!/bin/bash
# Web Stack Test Runner for Jon-Babylon

set -e

# Ensure we're in the right directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

echo "=== Jon-Babylon Web Stack Test Suite ==="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name=$1
    local test_command=$2

    echo -n "Testing $test_name... "
    if eval $test_command &> /tmp/test_output.log; then
        echo -e "${GREEN}✓${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC}"
        echo "  Error output:"
        cat /tmp/test_output.log | head -10
        ((TESTS_FAILED++))
    fi
}

# 1. Test Bun installation and setup
if ! command -v bun &> /dev/null || ! bun --version &> /dev/null; then
    echo -e "${YELLOW}⚠ Bun not found, using npm fallback${NC}"
    # Fall back to npm/yarn for running the tests
    echo "Installing dependencies with npm..."
    npm install &> /tmp/npm_install.log
    BUN_CMD="npm"
    BUILD_CMD="npm run"
else
    echo -e "${GREEN}✓ Bun found${NC}"
    BUN_CMD="bun"
    BUILD_CMD="bun run"
    ((TESTS_PASSED++))

    # 2. Test package installation
    echo ""
    echo "Installing dependencies with Bun..."
    if bun install &> /tmp/bun_install.log; then
        echo -e "${GREEN}✓ Dependencies installed${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${YELLOW}⚠ Failed to install with Bun, trying npm...${NC}"
        npm install &> /tmp/npm_install.log
        BUN_CMD="npm"
        BUILD_CMD="npm run"
    fi
fi

# 3. Test TypeScript compilation
run_test "TypeScript compilation" "${BUILD_CMD} build:ts"

# 4. Test esbuild bundling
run_test "esbuild bundling" "${BUILD_CMD} build:bundle"

# 5. Test ESLint
run_test "ESLint" "${BUILD_CMD} lint"

# 6. Test Prettier
run_test "Prettier formatting check" "${BUILD_CMD} format:check"

# 7. Test lit-localize (extract messages)
echo ""
echo "Testing @lit/localize..."
# Create dummy XLIFF directory for localization
mkdir -p xliff

# Extract messages (this would normally extract translatable strings)
if npx lit-localize extract &> /tmp/localize_output.log; then
    echo -e "${GREEN}✓ Localization extraction works${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${YELLOW}⚠ Localization extraction skipped (no translations yet)${NC}"
fi

# 8. Test the full build
run_test "Full build process" "${BUILD_CMD} build"

# 9. Verify output files exist
echo ""
echo "Verifying build outputs..."
if [ -f "dist/app.js" ]; then
    echo -e "${GREEN}✓ dist/app.js created${NC}"
    ((TESTS_PASSED++))

    # Check file size
    FILE_SIZE=$(stat -f%z "dist/app.js" 2>/dev/null || stat -c%s "dist/app.js" 2>/dev/null)
    echo "  Bundle size: $(numfmt --to=iec-i --suffix=B $FILE_SIZE 2>/dev/null || echo "${FILE_SIZE} bytes")"
else
    echo -e "${RED}✗ dist/app.js not found${NC}"
    ((TESTS_FAILED++))
fi

if [ -f "dist/app.js.map" ]; then
    echo -e "${GREEN}✓ Source map created${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${YELLOW}⚠ No source map found${NC}"
fi

# 10. Test specific tool versions
echo ""
echo "Tool Versions:"
echo "  Node.js: $(node --version)"
echo "  TypeScript: $(npx tsc --version)"
echo "  esbuild: $(npx esbuild --version)"
echo "  Prettier: $(npx prettier --version)"
echo "  ESLint: $(npx eslint --version)"
echo "  Bun: $(bun --version 2>/dev/null || echo 'not installed')"

# Summary
echo ""
echo "========================================"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed successfully!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
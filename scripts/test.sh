#!/bin/bash
# Comprehensive Test Runner for Jon-Babylon Docker Image
# Tests all programming languages, tools, linters, and formatters

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results tracking
PASSED_TESTS=()
FAILED_TESTS=()
SKIPPED_TESTS=()

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "PASS")
            echo -e "${GREEN}✓${NC} $message"
            ;;
        "FAIL")
            echo -e "${RED}✗${NC} $message"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ${NC} $message"
            ;;
        "WARN")
            echo -e "${YELLOW}⚠${NC} $message"
            ;;
        *)
            echo "$message"
            ;;
    esac
}

# Function to run a test
run_test() {
    local test_name=$1
    local test_dir=$2
    local test_script=$3

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_status "INFO" "Running $test_name tests..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ -d "$test_dir" ] && [ -f "$test_dir/$test_script" ]; then
        cd "$test_dir"
        if bash "$test_script"; then
            PASSED_TESTS+=("$test_name")
            print_status "PASS" "$test_name tests completed successfully"
        else
            FAILED_TESTS+=("$test_name")
            print_status "FAIL" "$test_name tests failed"
        fi
        cd "$SCRIPT_DIR"
    else
        SKIPPED_TESTS+=("$test_name")
        print_status "WARN" "$test_name tests skipped (not found)"
    fi
}

# Main test execution
echo "════════════════════════════════════════════════════════════"
echo "       Jon-Babylon Docker Image - Comprehensive Test Suite"
echo "════════════════════════════════════════════════════════════"
echo ""
print_status "INFO" "Starting comprehensive test suite..."
print_status "INFO" "Test directory: $SCRIPT_DIR"
echo ""

# Core Programming Languages
echo "┌──────────────────────────────────────┐"
echo "│   Core Programming Languages         │"
echo "└──────────────────────────────────────┘"

run_test "Java" "tests/java" "run_test.sh"
run_test "Kotlin" "tests/kotlin" "run_test.sh"
run_test "Clojure" "tests/clojure" "run_test.sh"
run_test "Python" "tests/python" "run_test.sh"
run_test "Rust" "tests/rust" "run_test.sh"
run_test "C" "tests/c" "run_test.sh"
run_test "C++" "tests/cpp" "run_test.sh"
run_test "Node.js/TypeScript" "tests/nodejs" "run_test.sh"

# Web Stack
echo ""
echo "┌──────────────────────────────────────┐"
echo "│   Web Development Stack              │"
echo "└──────────────────────────────────────┘"

run_test "Web (Lit/TypeScript/esbuild)" "tests/web" "run_test.sh"

# Build Tools
echo ""
echo "┌──────────────────────────────────────┐"
echo "│   Build Tools & Package Managers     │"
echo "└──────────────────────────────────────┘"

# Test build tools directly
echo ""
print_status "INFO" "Testing build tools..."

# Maven
if command -v mvn &> /dev/null; then
    mvn --version && print_status "PASS" "Maven installed"
else
    print_status "FAIL" "Maven not found"
fi

# Gradle
if command -v gradle &> /dev/null; then
    gradle --version && print_status "PASS" "Gradle installed"
else
    print_status "FAIL" "Gradle not found"
fi

# Leiningen
if command -v lein &> /dev/null; then
    lein version && print_status "PASS" "Leiningen installed"
else
    print_status "FAIL" "Leiningen not found"
fi

# Cargo
if command -v cargo &> /dev/null; then
    cargo --version && print_status "PASS" "Cargo installed"
else
    print_status "FAIL" "Cargo not found"
fi

# Linters and Formatters
echo ""
echo "┌──────────────────────────────────────┐"
echo "│   Linters and Formatters             │"
echo "└──────────────────────────────────────┘"

echo ""
print_status "INFO" "Testing linters and formatters..."

# Java/Kotlin linters
if command -v ktlint &> /dev/null; then
    ktlint --version && print_status "PASS" "ktlint installed"
else
    print_status "WARN" "ktlint not found"
fi

if command -v detekt &> /dev/null; then
    detekt --version && print_status "PASS" "detekt installed"
else
    print_status "WARN" "detekt not found"
fi

# Clojure linters
if command -v clj-kondo &> /dev/null; then
    clj-kondo --version && print_status "PASS" "clj-kondo installed"
else
    print_status "WARN" "clj-kondo not found"
fi

# Python linters
if command -v black &> /dev/null; then
    black --version && print_status "PASS" "black installed"
else
    print_status "WARN" "black not found"
fi

if command -v flake8 &> /dev/null; then
    flake8 --version && print_status "PASS" "flake8 installed"
else
    print_status "WARN" "flake8 not found"
fi

if command -v ruff &> /dev/null; then
    ruff --version && print_status "PASS" "ruff installed"
else
    print_status "WARN" "ruff not found"
fi

# Rust linters
if command -v clippy-driver &> /dev/null; then
    clippy-driver --version && print_status "PASS" "clippy installed"
else
    print_status "WARN" "clippy not found"
fi

if command -v rustfmt &> /dev/null; then
    rustfmt --version && print_status "PASS" "rustfmt installed"
else
    print_status "WARN" "rustfmt not found"
fi

# JavaScript/TypeScript linters
if command -v eslint &> /dev/null; then
    eslint --version && print_status "PASS" "eslint installed"
else
    print_status "WARN" "eslint not found"
fi

if command -v prettier &> /dev/null; then
    prettier --version && print_status "PASS" "prettier installed"
else
    print_status "WARN" "prettier not found"
fi

# Test Summary
echo ""
echo "════════════════════════════════════════════════════════════"
echo "                      TEST SUMMARY"
echo "════════════════════════════════════════════════════════════"
echo ""

# Calculate totals
TOTAL_TESTS=$((${#PASSED_TESTS[@]} + ${#FAILED_TESTS[@]} + ${#SKIPPED_TESTS[@]}))

# Print summary
if [ ${#PASSED_TESTS[@]} -gt 0 ]; then
    echo -e "${GREEN}Passed Tests (${#PASSED_TESTS[@]}/${TOTAL_TESTS}):${NC}"
    for test in "${PASSED_TESTS[@]}"; do
        echo -e "  ${GREEN}✓${NC} $test"
    done
fi

if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
    echo ""
    echo -e "${RED}Failed Tests (${#FAILED_TESTS[@]}/${TOTAL_TESTS}):${NC}"
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "  ${RED}✗${NC} $test"
    done
fi

if [ ${#SKIPPED_TESTS[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Skipped Tests (${#SKIPPED_TESTS[@]}/${TOTAL_TESTS}):${NC}"
    for test in "${SKIPPED_TESTS[@]}"; do
        echo -e "  ${YELLOW}⚠${NC} $test"
    done
fi

echo ""
echo "────────────────────────────────────────────────────────────"

# Exit status
if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
    print_status "FAIL" "Test suite completed with failures"
    exit 1
else
    print_status "PASS" "All available tests passed successfully!"
    exit 0
fi
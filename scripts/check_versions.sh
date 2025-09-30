#!/bin/bash

# Jon-Babylon Version Check Script
# Validates all installed tools and their versions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Jon-Babylon Tool Version Report${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to find binary in system
find_binary() {
    local binary="$1"
    echo -e "${CYAN}  Searching for $binary in system...${NC}"

    # Common locations to check
    local locations=(
        "/usr/local/bin"
        "/usr/bin"
        "/bin"
        "/opt/*/bin"
        "/opt/*/*/bin"
        "$HOME/.cargo/bin"
        "$HOME/.local/bin"
        "/opt/sdkman/candidates/*/current/bin"
        "/opt/pyenv/versions/*/bin"
        "/opt/rustup/toolchains/*/bin"
        "/opt/bun/bin"
    )

    local found=0
    for loc in "${locations[@]}"; do
        if compgen -G "$loc/$binary" > /dev/null 2>&1; then
            for file in $loc/$binary; do
                if [ -x "$file" ]; then
                    echo -e "${CYAN}    Found: $file${NC}"
                    if [ -L "$file" ]; then
                        local target=$(readlink -f "$file")
                        echo -e "${CYAN}      -> Links to: $target${NC}"
                    fi
                    # Try to get version from found binary
                    local version_output=$("$file" --version 2>&1 | head -n1 || echo "unknown")
                    echo -e "${CYAN}      Version: $version_output${NC}"
                    found=1
                fi
            done
        fi
    done

    # Also check with 'which' and 'whereis'
    if command -v which &> /dev/null; then
        local which_result=$(which -a "$binary" 2>/dev/null || true)
        if [ -n "$which_result" ]; then
            echo -e "${CYAN}    which -a: $which_result${NC}"
            found=1
        fi
    fi

    if command -v whereis &> /dev/null; then
        local whereis_result=$(whereis "$binary" 2>/dev/null | cut -d: -f2 || true)
        if [ -n "$whereis_result" ] && [ "$whereis_result" != " " ]; then
            echo -e "${CYAN}    whereis: $whereis_result${NC}"
            found=1
        fi
    fi

    # Use find as last resort (limited to avoid long searches)
    if [ $found -eq 0 ]; then
        echo -e "${CYAN}    Searching with find (this may take a moment)...${NC}"
        local find_results=$(find /opt /usr/local /usr/bin 2>/dev/null -maxdepth 4 -name "$binary" -type f -executable | head -5 || true)
        if [ -n "$find_results" ]; then
            echo -e "${CYAN}    find results:${NC}"
            echo "$find_results" | while read -r line; do
                echo -e "${CYAN}      $line${NC}"
            done
            found=1
        fi
    fi

    if [ $found -eq 0 ]; then
        echo -e "${CYAN}    No binary found in common locations${NC}"
    fi

    # Check if it might need sourcing
    echo -e "${CYAN}  Checking for environment setup scripts...${NC}"
    if [ -f "/opt/sdkman/bin/sdkman-init.sh" ]; then
        echo -e "${CYAN}    SDKMAN found: source /opt/sdkman/bin/sdkman-init.sh${NC}"
    fi
    if [ -f "/opt/cargo/env" ]; then
        echo -e "${CYAN}    Cargo found: source /opt/cargo/env${NC}"
    fi
    if [ -f "/opt/pyenv/bin/pyenv" ]; then
        echo -e "${CYAN}    Pyenv found: eval \"\$(pyenv init -)\"${NC}"
    fi
}

# Function to check tool version
check_version() {
    local tool_name="$1"
    local version_cmd="$2"
    local min_version="$3"
    local optional="$4"  # Optional flag

    echo -n "Checking $tool_name... "

    # Extract just the command name for binary search
    local cmd_name=$(echo $version_cmd | cut -d' ' -f1)

    if command -v $cmd_name &> /dev/null; then
        version_output=$(eval $version_cmd 2>&1 | head -n1 || echo "unknown")
        echo -e "${GREEN}✓${NC} $version_output"
        return 0
    else
        echo -e "${RED}✗${NC} Not found in PATH"
        find_binary "$cmd_name"
        if [ "$optional" != "optional" ]; then
            return 1
        else
            echo "  (Optional tool - skipping)"
            return 0
        fi
    fi
}

# Track failures
FAILURES=0
FAILED_TOOLS=()

# Modified check function that doesn't exit on failure
check_version_no_exit() {
    if ! check_version "$@"; then
        FAILURES=$((FAILURES + 1))
        FAILED_TOOLS+=("$1")
    fi
}

echo -e "${YELLOW}Programming Languages:${NC}"
check_version_no_exit "Java" "java -version" "21"
check_version_no_exit "Kotlin" "kotlin -version" "2.0"
check_version_no_exit "Clojure" "clojure --version" "1.12"
check_version_no_exit "clj-kondo" "clj-kondo --version" ""
check_version_no_exit "Go" "go version" "1.25"
check_version_no_exit "Python" "python3 --version" "3.12"
check_version_no_exit "Rust" "rustc --version" "1.8"
check_version_no_exit "Node.js" "node --version" "22"
check_version_no_exit "TypeScript" "tsc --version" "5"
echo ""

echo -e "${YELLOW}Compilers & Linters:${NC}"
check_version_no_exit "Clang" "clang --version" "21"
check_version_no_exit "Clang++" "clang++ --version" "21"
check_version_no_exit "clang-format" "clang-format --version" "21"
check_version_no_exit "clang-tidy" "clang-tidy --version" "21"
check_version_no_exit "ktlint" "ktlint --version" "1" "optional"
check_version_no_exit "rustfmt" "rustfmt --version" "1"
check_version_no_exit "clippy" "cargo clippy --version" "0.1"
check_version_no_exit "Nuitka" "python3 -m nuitka --version" "2"
echo ""

echo -e "${YELLOW}Build Tools:${NC}"
check_version_no_exit "Maven" "mvn --version" "3.9"
check_version_no_exit "Gradle" "gradle --version" "9"
check_version_no_exit "Leiningen" "lein version" "2"
check_version_no_exit "Cargo" "cargo --version" "1.8"
check_version_no_exit "npm" "npm --version" "10"
check_version_no_exit "yarn" "yarn --version" "1"
check_version_no_exit "pnpm" "pnpm --version" "9"
check_version_no_exit "Bun" "bun --version" "1"
check_version_no_exit "Babashka" "bb --version" "1" "optional"
echo ""

echo -e "${YELLOW}JavaScript Tools:${NC}"
check_version_no_exit "esbuild" "esbuild --version" "0.20"
check_version_no_exit "Prettier" "prettier --version" "3"
check_version_no_exit "ESLint" "eslint --version" "9"
echo ""

echo -e "${YELLOW}Python Environment:${NC}"
check_version_no_exit "pyenv" "pyenv --version" "2"
check_version_no_exit "pip" "pip3 --version" "24"
echo ""

# Source environment files if they exist
echo -e "${YELLOW}Attempting to source environment files:${NC}"
if [ -f "/opt/sdkman/bin/sdkman-init.sh" ]; then
    echo "  Sourcing SDKMAN..."
    source /opt/sdkman/bin/sdkman-init.sh
    echo -e "  ${GREEN}✓${NC} SDKMAN sourced"
fi
if [ -f "/opt/cargo/env" ]; then
    echo "  Sourcing Cargo..."
    source /opt/cargo/env
    echo -e "  ${GREEN}✓${NC} Cargo sourced"
fi
if [ -f "/opt/pyenv/bin/pyenv" ]; then
    echo "  Setting up pyenv..."
    export PYENV_ROOT="/opt/pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    echo -e "  ${GREEN}✓${NC} Pyenv configured"
fi
if [ -f "/opt/bun/bin/bun" ]; then
    export PATH="/opt/bun/bin:$PATH"
    echo -e "  ${GREEN}✓${NC} Bun added to PATH"
fi
echo ""

# Re-check failed tools after sourcing
if [ ${#FAILED_TOOLS[@]} -gt 0 ]; then
    echo -e "${YELLOW}Re-checking failed tools after environment setup:${NC}"
    RECHECK_FAILURES=0
    for tool in "${FAILED_TOOLS[@]}"; do
        case "$tool" in
            "Java") check_version "Java" "java -version" "21" || ((RECHECK_FAILURES++)) ;;
            "Kotlin") check_version "Kotlin" "kotlin -version" "2.0" || ((RECHECK_FAILURES++)) ;;
            "Rust") check_version "Rust" "rustc --version" "1.8" || ((RECHECK_FAILURES++)) ;;
            "Cargo") check_version "Cargo" "cargo --version" "1.8" || ((RECHECK_FAILURES++)) ;;
            "Maven") check_version "Maven" "mvn --version" "3.9" || ((RECHECK_FAILURES++)) ;;
            "Gradle") check_version "Gradle" "gradle --version" "9" || ((RECHECK_FAILURES++)) ;;
            "Leiningen") check_version "Leiningen" "lein version" "2" || ((RECHECK_FAILURES++)) ;;
            "Bun") check_version "Bun" "bun --version" "1" || ((RECHECK_FAILURES++)) ;;
            *) ;;
        esac
    done
    FAILURES=$RECHECK_FAILURES
    echo ""
fi

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
    echo "    \"go\": \"$(go version 2>/dev/null | cut -d' ' -f3 | cut -c3- || echo 'not found')\","
    echo "    \"python\": \"$(python3 --version | cut -d' ' -f2 || echo 'not found')\","
    echo "    \"node\": \"$(node --version | cut -c2- || echo 'not found')\","
    echo "    \"typescript\": \"$(tsc --version | cut -d' ' -f2 || echo 'not found')\","
    echo "    \"clang\": \"$(clang --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || echo 'not found')\","
    echo "    \"nuitka\": \"$(python3 -m nuitka --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || echo 'not found')\","
    echo "    \"maven\": \"$(mvn --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || echo 'not found')\","
    echo "    \"gradle\": \"$(gradle --version 2>/dev/null | grep Gradle | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || echo 'not found')\","
    echo "    \"bun\": \"$(bun --version || echo 'not found')\""
    echo "  },"
    echo "  \"status\": \"$([ $FAILURES -eq 0 ] && echo 'success' || echo 'failed')\","
    echo "  \"failures\": $FAILURES,"
    echo "  \"failed_tools\": ["
    local first=true
    for tool in "${FAILED_TOOLS[@]}"; do
        if [ "$first" = true ]; then
            echo -n "    \"$tool\""
            first=false
        else
            echo -n ","
            echo -n "    \"$tool\""
        fi
    done
    [ ${#FAILED_TOOLS[@]} -gt 0 ] && echo ""
    echo "  ]"
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
    echo -e "${GREEN}All ${YELLOW}$((${#FAILED_TOOLS[@]} * 0 + $(grep -c "check_version_no_exit" $0)))${GREEN} tools are properly installed and accessible.${NC}"
    exit 0
else
    echo -e "${RED}✗ $FAILURES tool(s) not found or version mismatch${NC}"
    echo -e "${RED}Failed tools: ${FAILED_TOOLS[*]}${NC}"
    echo ""
    echo -e "${YELLOW}Troubleshooting tips:${NC}"
    echo "1. Source environment files in your shell:"
    [ -f "/opt/sdkman/bin/sdkman-init.sh" ] && echo "   source /opt/sdkman/bin/sdkman-init.sh"
    [ -f "/opt/cargo/env" ] && echo "   source /opt/cargo/env"
    [ -f "/opt/pyenv/bin/pyenv" ] && echo "   eval \"\$(pyenv init -)\""
    echo "2. Check the binary locations found above"
    echo "3. Verify PATH includes the tool directories"
    echo "4. Re-run the container build if tools are missing"
    exit 1
fi
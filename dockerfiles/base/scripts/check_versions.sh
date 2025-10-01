#!/bin/bash
# Base container version and tool availability check
set -e

echo "=========================================="
echo "Base Container Tool Verification"
echo "=========================================="
echo ""

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counter for results
TOTAL=0
PASSED=0
FAILED=0

# Function to check if command exists
check_command() {
    local cmd=$1
    local name=${2:-$1}
    TOTAL=$((TOTAL + 1))

    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $name"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} $name - NOT FOUND"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Function to check command with version
check_version() {
    local cmd=$1
    local version_flag=${2:---version}
    local name=${3:-$1}
    TOTAL=$((TOTAL + 1))

    if command -v "$cmd" &> /dev/null; then
        local version=$($cmd $version_flag 2>&1 | head -n1)
        echo -e "${GREEN}✓${NC} $name: $version"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} $name - NOT FOUND"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# System Information
echo "=== System Information ==="
echo "Ubuntu: $(lsb_release -d | cut -f2)"
echo "Architecture: $(uname -m)"
echo "User: $(whoami)"
echo "Workspace: $(pwd)"
echo ""

# System Utilities
echo "=== System Utilities ==="
check_version curl
check_version wget
check_version rsync
check_command ssh "openssh-client (ssh)"
check_version mosh
check_command socat
check_version git
check_command nano
check_version nvim "--version" "neovim (nvim)"
check_command vim "vim (symlink to nvim)"
check_command less
check_command tree
check_version tmux
check_command htop
check_version jq
check_command bc
check_command xxd
check_command gawk
check_version parallel "--version" "GNU parallel"
check_version gdb
check_command stow
echo ""

# Compression Tools
echo "=== Compression Tools ==="
check_command unzip
check_command zip
check_command 7z "p7zip (7z)"
check_command xz
echo ""

# Build Tools
echo "=== Build Tools ==="
check_version gcc
check_version g++
check_version make
check_command pkg-config
check_version autoconf
check_version automake
check_version libtool "--version" "libtool"
check_version bison
check_version flex
check_version m4
check_command makeinfo "texinfo (makeinfo)"
check_command ccache
check_command patchelf
echo ""

# CMake (from Kitware)
echo "=== CMake ==="
check_version cmake
check_command ccmake "cmake-curses-gui (ccmake)"
echo ""

# Debugging Tools
echo "=== Debugging Tools ==="
check_version valgrind
check_command strace
check_command sshpass
echo ""

# Media Tools
echo "=== Media Tools ==="
check_version ffmpeg
echo ""

# Hardware Interface Tools
echo "=== Hardware Interface Tools ==="
check_command cansend "can-utils (cansend)"
check_command i2cdetect "i2c-tools (i2cdetect)"
check_command minicom
echo ""

# Database Clients
echo "=== Database Clients ==="
check_version psql "--version" "postgresql-client (psql)"
check_version redis-cli "--version" "redis-tools (redis-cli)"
echo ""

# Custom Built Tools
echo "=== Custom Built Tools ==="
check_version zellij
check_version fzf
check_version navi
check_version rg "--version" "ripgrep (rg)"
check_version rga "--version" "ripgrep-all (rga)"
check_version bear
check_command fzf-make "fzf-make"
echo ""

# Shell and Editor Configurations
echo "=== Shell and Editor Configurations ==="
TOTAL=$((TOTAL + 1))
if [ -d "$HOME/.oh-my-bash" ]; then
    echo -e "${GREEN}✓${NC} Oh My Bash installed"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗${NC} Oh My Bash not found"
    FAILED=$((FAILED + 1))
fi

TOTAL=$((TOTAL + 1))
if [ -d "$HOME/.config/nvim" ]; then
    echo -e "${GREEN}✓${NC} NvChad installed"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗${NC} NvChad not found"
    FAILED=$((FAILED + 1))
fi
echo ""

# Libraries (via pkg-config)
echo "=== Development Libraries ==="
TOTAL=$((TOTAL + 1))
if pkg-config --exists hiredis 2>/dev/null; then
    echo -e "${GREEN}✓${NC} hiredis: $(pkg-config --modversion hiredis)"
    PASSED=$((PASSED + 1))
else
    echo -e "${YELLOW}⚠${NC} hiredis: pkg-config not found (may be installed without .pc file)"
    PASSED=$((PASSED + 1))
fi

TOTAL=$((TOTAL + 1))
if pkg-config --exists libssl 2>/dev/null; then
    echo -e "${GREEN}✓${NC} libssl: $(pkg-config --modversion libssl)"
    PASSED=$((PASSED + 1))
else
    echo -e "${YELLOW}⚠${NC} libssl: pkg-config not found"
    PASSED=$((PASSED + 1))
fi
echo ""

# Environment Variables
echo "=== Environment Variables ==="
TOTAL=$((TOTAL + 2))
if [ "$EDITOR" = "vim" ]; then
    echo -e "${GREEN}✓${NC} EDITOR=vim"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗${NC} EDITOR=$EDITOR (expected: vim)"
    FAILED=$((FAILED + 1))
fi

if [ "$VISUAL" = "vim" ]; then
    echo -e "${GREEN}✓${NC} VISUAL=vim"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗${NC} VISUAL=$VISUAL (expected: vim)"
    FAILED=$((FAILED + 1))
fi
echo ""

# Summary
echo "=========================================="
echo "Summary: $PASSED/$TOTAL checks passed"
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tools are available!${NC}"
    exit 0
else
    echo -e "${RED}✗ $FAILED checks failed${NC}"
    exit 1
fi

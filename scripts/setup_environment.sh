#!/bin/bash
# Environment setup script using GNU Stow
# Sets up all tool paths and environment variables

set -e

echo "=== Setting up development environment with GNU Stow ==="

# Install stow if not present
if ! command -v stow &> /dev/null; then
    apt-get update && apt-get install -y stow
fi

# Create stow directory structure
mkdir -p /opt/stow
mkdir -p /usr/local/bin
mkdir -p /usr/local/lib
mkdir -p /usr/local/share

# Function to create stow package
create_stow_package() {
    local name="$1"
    local source="$2"
    local target="/opt/stow/$name"

    echo "Creating stow package for $name..."
    mkdir -p "$target/bin"

    # Create symlinks in stow package
    if [ -d "$source/bin" ]; then
        for binary in "$source/bin"/*; do
            if [ -f "$binary" ] || [ -L "$binary" ]; then
                ln -sf "$binary" "$target/bin/$(basename $binary)"
            fi
        done
    elif [ -f "$source" ]; then
        ln -sf "$source" "$target/bin/$(basename $source)"
    fi

    # Stow the package
    cd /opt/stow
    stow -v "$name" -t /usr/local
}

# Setup SDKMAN tools
if [ -d "/opt/sdkman" ]; then
    echo "Setting up SDKMAN tools..."

    # Java
    if [ -d "/opt/sdkman/candidates/java/current" ]; then
        create_stow_package "java" "/opt/sdkman/candidates/java/current"
        export JAVA_HOME="/opt/sdkman/candidates/java/current"
    fi

    # Kotlin
    if [ -d "/opt/sdkman/candidates/kotlin/current" ]; then
        create_stow_package "kotlin" "/opt/sdkman/candidates/kotlin/current"
    fi

    # Maven
    if [ -d "/opt/sdkman/candidates/maven/current" ]; then
        create_stow_package "maven" "/opt/sdkman/candidates/maven/current"
        export MAVEN_HOME="/opt/sdkman/candidates/maven/current"
    fi

    # Gradle
    if [ -d "/opt/sdkman/candidates/gradle/current" ]; then
        create_stow_package "gradle" "/opt/sdkman/candidates/gradle/current"
    fi

    # Leiningen
    if [ -d "/opt/sdkman/candidates/leiningen/current" ]; then
        create_stow_package "leiningen" "/opt/sdkman/candidates/leiningen/current"
    fi
fi

# Setup Rust/Cargo
if [ -d "/opt/cargo" ]; then
    echo "Setting up Rust/Cargo..."
    create_stow_package "rust" "/opt/cargo"

    # Set default toolchain
    if [ -f "/opt/cargo/bin/rustup" ]; then
        /opt/cargo/bin/rustup default stable || true
    fi

    export CARGO_HOME="/opt/cargo"
    export RUSTUP_HOME="/opt/rustup"
fi

# Setup Go
if [ -d "/usr/local/go" ]; then
    echo "Setting up Go..."
    create_stow_package "go" "/usr/local/go"
    export GOPATH="/home/developer/go"
    export GOROOT="/usr/local/go"
fi

# Setup Pyenv
if [ -d "/opt/pyenv" ]; then
    echo "Setting up Pyenv..."
    create_stow_package "pyenv" "/opt/pyenv"
    export PYENV_ROOT="/opt/pyenv"
fi

# Setup Bun
if [ -d "/opt/bun" ]; then
    echo "Setting up Bun..."
    create_stow_package "bun" "/opt/bun"
fi

# Setup Node.js tools
if command -v npm &> /dev/null; then
    echo "Setting up Node.js global tools..."
    # These are already in /usr/local/bin from npm -g installs
fi

# Create comprehensive environment file
cat > /etc/profile.d/00-jon-babylon.sh << 'EOF'
# Jon-Babylon Environment Setup

# Basic PATH
export PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

# Java/SDKMAN
if [ -d "/opt/sdkman" ]; then
    export SDKMAN_DIR="/opt/sdkman"
    export JAVA_HOME="/opt/sdkman/candidates/java/current"
    export MAVEN_HOME="/opt/sdkman/candidates/maven/current"
    export GRADLE_HOME="/opt/sdkman/candidates/gradle/current"

    # Don't source init script in non-interactive shells
    if [[ $- == *i* ]] && [ -s "/opt/sdkman/bin/sdkman-init.sh" ]; then
        source "/opt/sdkman/bin/sdkman-init.sh"
    else
        # Just add to PATH for non-interactive
        export PATH="$JAVA_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin:$PATH"
        for candidate_dir in /opt/sdkman/candidates/*/current/bin; do
            [ -d "$candidate_dir" ] && export PATH="$candidate_dir:$PATH"
        done
    fi
fi

# Rust/Cargo
if [ -d "/opt/cargo" ]; then
    export CARGO_HOME="/opt/cargo"
    export RUSTUP_HOME="/opt/rustup"
    export PATH="/opt/cargo/bin:$PATH"

    # Ensure stable toolchain is default
    if [ -f "/opt/cargo/bin/rustup" ]; then
        /opt/cargo/bin/rustup default stable 2>/dev/null || true
    fi
fi

# Go
if [ -d "/usr/local/go" ]; then
    export GOROOT="/usr/local/go"
    export GOPATH="/home/developer/go"
    export PATH="/usr/local/go/bin:$GOPATH/bin:$PATH"
fi

# Python/Pyenv
if [ -d "/opt/pyenv" ]; then
    export PYENV_ROOT="/opt/pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"

    # Initialize pyenv if in interactive shell
    if [[ $- == *i* ]] && command -v pyenv &> /dev/null; then
        eval "$(pyenv init -)"
    fi
fi

# Bun
if [ -d "/opt/bun" ]; then
    export BUN_INSTALL="/opt/bun"
    export PATH="/opt/bun/bin:$PATH"
fi

# Node/NPM globals
export PATH="/usr/local/lib/node_modules/.bin:$PATH"

# Clang/LLVM
if [ -d "/usr/lib/llvm-21" ]; then
    export PATH="/usr/lib/llvm-21/bin:$PATH"
fi

# User local bin
export PATH="$HOME/.local/bin:$PATH"

# Set common environment variables
export EDITOR="vim"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Nuitka cache
export NUITKA_CACHE_DIR="/opt/nuitka-cache"
export CC="clang"
export CXX="clang++"

EOF

# Make sure profile is sourced for current session
source /etc/profile.d/00-jon-babylon.sh

# Fix permissions
chown -R developer:developer /opt/stow 2>/dev/null || true
chown -R developer:developer /home/developer 2>/dev/null || true

echo "✓ Environment setup complete!"
echo ""
echo "Tools are now available in PATH. For interactive shells:"
echo "  - SDKMAN will be automatically initialized"
echo "  - Pyenv will be automatically initialized"
echo "  - All tools are accessible via /usr/local/bin (managed by stow)"
echo ""
echo "To manually source the environment:"
echo "  source /etc/profile.d/00-jon-babylon.sh"
#!/bin/bash
# Environment setup script - Creates symlinks for all tools
# Sets up all tool paths and environment variables

set -e

echo "=== Setting up development environment ==="

# Create required directories
mkdir -p /usr/local/bin
mkdir -p /usr/local/lib
mkdir -p /usr/local/share

# Function to create symlinks for binaries
create_symlinks() {
    local source_dir="$1"
    local target_dir="${2:-/usr/local/bin}"

    if [ -d "$source_dir" ]; then
        echo "  Linking binaries from $source_dir..."
        for binary in "$source_dir"/*; do
            if [ -f "$binary" ] || [ -L "$binary" ]; then
                local name=$(basename "$binary")
                # Remove existing link if it exists
                rm -f "$target_dir/$name"
                ln -sf "$binary" "$target_dir/$name"
            fi
        done
    fi
}

# Setup SDKMAN tools
if [ -d "/opt/sdkman" ]; then
    echo "Setting up SDKMAN tools..."

    # Java
    if [ -d "/opt/sdkman/candidates/java/current/bin" ]; then
        create_symlinks "/opt/sdkman/candidates/java/current/bin"
        export JAVA_HOME="/opt/sdkman/candidates/java/current"
    fi

    # Kotlin
    if [ -d "/opt/sdkman/candidates/kotlin/current/bin" ]; then
        create_symlinks "/opt/sdkman/candidates/kotlin/current/bin"
    fi

    # Maven
    if [ -d "/opt/sdkman/candidates/maven/current/bin" ]; then
        create_symlinks "/opt/sdkman/candidates/maven/current/bin"
        export MAVEN_HOME="/opt/sdkman/candidates/maven/current"
    fi

    # Gradle
    if [ -d "/opt/sdkman/candidates/gradle/current/bin" ]; then
        create_symlinks "/opt/sdkman/candidates/gradle/current/bin"
    fi

    # Leiningen
    if [ -d "/opt/sdkman/candidates/leiningen/current/bin" ]; then
        create_symlinks "/opt/sdkman/candidates/leiningen/current/bin"
    fi
fi

# Setup Rust/Cargo
if [ -d "/opt/cargo/bin" ]; then
    echo "Setting up Rust/Cargo..."

    # Set default toolchain first
    if [ -f "/opt/cargo/bin/rustup" ]; then
        export CARGO_HOME="/opt/cargo"
        export RUSTUP_HOME="/opt/rustup"
        /opt/cargo/bin/rustup default stable 2>/dev/null || true
    fi

    # Now create symlinks
    create_symlinks "/opt/cargo/bin"
fi

# Setup Go
if [ -d "/usr/local/go/bin" ]; then
    echo "Setting up Go..."
    create_symlinks "/usr/local/go/bin"
    export GOPATH="/home/developer/go"
    export GOROOT="/usr/local/go"
fi

# Setup Pyenv
if [ -d "/opt/pyenv/bin" ]; then
    echo "Setting up Pyenv..."
    create_symlinks "/opt/pyenv/bin"
    export PYENV_ROOT="/opt/pyenv"

    # Also link python binaries from the active version
    if [ -d "/opt/pyenv/versions/3.13.7/bin" ]; then
        # Link python3 and pip3 to be available globally
        ln -sf /opt/pyenv/versions/3.13.7/bin/python3 /usr/local/bin/python
        ln -sf /opt/pyenv/versions/3.13.7/bin/python3 /usr/local/bin/python3
        ln -sf /opt/pyenv/versions/3.13.7/bin/pip3 /usr/local/bin/pip
        ln -sf /opt/pyenv/versions/3.13.7/bin/pip3 /usr/local/bin/pip3
    fi

    # Create and fix permissions for pyenv shims directory
    mkdir -p /opt/pyenv/shims
    chmod 755 /opt/pyenv/shims
    chown -R developer:developer /opt/pyenv/shims 2>/dev/null || true
fi

# Setup Bun
if [ -d "/opt/bun/bin" ]; then
    echo "Setting up Bun..."
    create_symlinks "/opt/bun/bin"
fi

# Create comprehensive environment file
cat > /etc/profile.d/00-jon-babylon.sh << 'EOF'
# Jon-Babylon Environment Setup

# Basic PATH - Include /usr/local/bin FIRST
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
    fi
fi

# Rust/Cargo
if [ -d "/opt/cargo" ]; then
    export CARGO_HOME="/opt/cargo"
    export RUSTUP_HOME="/opt/rustup"
    export PATH="/opt/cargo/bin:$PATH"
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

# Also create a simple bashrc that sources the profile
cat > /etc/bash.bashrc << 'EOF'
# System-wide .bashrc file for interactive bash(1) shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Source global definitions
if [ -f /etc/profile.d/00-jon-babylon.sh ]; then
    . /etc/profile.d/00-jon-babylon.sh
fi

# Set prompt
PS1='[\u@\h \W]\$ '

# Enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

# Common aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
EOF

# Source environment for current session
source /etc/profile.d/00-jon-babylon.sh

# Fix permissions
chown -R developer:developer /home/developer 2>/dev/null || true

echo "✓ Environment setup complete!"
echo ""
echo "Tools are now available in /usr/local/bin and PATH is configured."
echo ""
echo "Verification of key tools:"
which java 2>/dev/null && echo "  ✓ Java: $(java -version 2>&1 | head -n1)"
which kotlin 2>/dev/null && echo "  ✓ Kotlin: found at $(which kotlin)"
which rustc 2>/dev/null && echo "  ✓ Rust: $(rustc --version)"
which go 2>/dev/null && echo "  ✓ Go: $(go version)"
which python 2>/dev/null && echo "  ✓ Python: $(python --version)"
which mvn 2>/dev/null && echo "  ✓ Maven: found at $(which mvn)"
which gradle 2>/dev/null && echo "  ✓ Gradle: found at $(which gradle)"
which cargo 2>/dev/null && echo "  ✓ Cargo: found at $(which cargo)"
which node 2>/dev/null && echo "  ✓ Node.js: $(node --version)"
which bun 2>/dev/null && echo "  ✓ Bun: $(bun --version)"
#!/bin/bash
# Rust Installation via rustup
# Official Rust toolchain installer

set -e

echo "=== Installing Rust via rustup ==="

# Install prerequisites
apt-get update
apt-get install -y curl build-essential

# Detect architecture
ARCH=$(uname -m)
echo "Detected architecture: $ARCH"

# Download and run rustup installer
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- -y \
    --default-toolchain stable \
    --profile default \
    --component rust-src \
    --component rustfmt \
    --component clippy

# Set up environment
export CARGO_HOME="/opt/cargo"
export RUSTUP_HOME="/opt/rustup"
export PATH="$CARGO_HOME/bin:$PATH"

# Move to system location
if [ -d "$HOME/.cargo" ]; then
    mv $HOME/.cargo/* $CARGO_HOME/ 2>/dev/null || true
    rm -rf $HOME/.cargo
fi
if [ -d "$HOME/.rustup" ]; then
    mv $HOME/.rustup/* $RUSTUP_HOME/ 2>/dev/null || true
    rm -rf $HOME/.rustup
fi

# Create environment file
cat > /etc/profile.d/rust.sh << 'EOF'
export CARGO_HOME="/opt/cargo"
export RUSTUP_HOME="/opt/rustup"
export PATH="$CARGO_HOME/bin:$PATH"
EOF

# Install common Rust tools
cargo install cargo-watch cargo-edit cargo-outdated cargo-audit

echo "✓ Rust installed successfully"
rustc --version
cargo --version
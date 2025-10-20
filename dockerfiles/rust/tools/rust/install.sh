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

# Create system directories
mkdir -p /opt/cargo /opt/rustup

# Move to system location
if [ -d "$HOME/.cargo" ]; then
    mv $HOME/.cargo/* /opt/cargo/ 2>/dev/null || true
    rm -rf $HOME/.cargo
fi
if [ -d "$HOME/.rustup" ]; then
    mv $HOME/.rustup/* /opt/rustup/ 2>/dev/null || true
    rm -rf $HOME/.rustup
fi

# Set up environment
export CARGO_HOME="/opt/cargo"
export RUSTUP_HOME="/opt/rustup"
export PATH="$CARGO_HOME/bin:$PATH"

# Create environment file
cat > /etc/profile.d/rust.sh << 'EOF'
export CARGO_HOME="/opt/cargo"
export RUSTUP_HOME="/opt/rustup"
export PATH="$CARGO_HOME/bin:$PATH"
EOF

# Source the environment for this session
source /etc/profile.d/rust.sh

# Set default toolchain (important for rustup symlinks to work)
$CARGO_HOME/bin/rustup default stable

# Install common Rust tools (install separately to avoid failing on one tool)
echo "Installing cargo tools..."
$CARGO_HOME/bin/cargo install cargo-watch || echo "Warning: cargo-watch failed to install"
$CARGO_HOME/bin/cargo install cargo-edit || echo "Warning: cargo-edit failed to install"
$CARGO_HOME/bin/cargo install cargo-audit || echo "Warning: cargo-audit failed to install"
# cargo-outdated is optional and may fail on some Rust versions
$CARGO_HOME/bin/cargo install cargo-outdated || echo "Warning: cargo-outdated failed to install (optional)"

echo "✓ Rust installed successfully"
$CARGO_HOME/bin/rustc --version
$CARGO_HOME/bin/cargo --version
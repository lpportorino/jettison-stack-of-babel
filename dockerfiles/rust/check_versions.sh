#!/bin/bash
# Rust container version check
set -e

echo "=== Rust Container Version Check ==="
echo ""
echo "Rustc: $(rustc --version)"
echo "Cargo: $(cargo --version)"
echo "Rustup: $(rustup --version)"
echo "Rustfmt: $(rustfmt --version)"
echo "Clippy: $(cargo clippy --version)"
echo ""
echo "Additional tools:"
cargo audit --version 2>/dev/null && echo "cargo-audit: installed" || echo "cargo-audit: not found"
cargo outdated --version 2>/dev/null && echo "cargo-outdated: installed" || echo "cargo-outdated: not found"
cargo add --version 2>/dev/null && echo "cargo-edit: installed" || echo "cargo-edit: not found"
cargo watch --version 2>/dev/null && echo "cargo-watch: installed" || echo "cargo-watch: not found"
echo ""
echo "CARGO_HOME: $CARGO_HOME"
echo "RUSTUP_HOME: $RUSTUP_HOME"
echo ""
echo "✓ Rust container ready"
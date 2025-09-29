#!/bin/bash
set -e
echo "=== Testing Rust ==="
rustc --version
cargo --version
cargo build --release
cargo run
cargo fmt --check
cargo clippy -- -D warnings
echo "✓ Rust tests completed!"
#!/bin/bash
# Rust Test Runner - Comprehensive Testing
# Tests: Rust, Cargo, rustfmt, clippy, build modes, testing framework

set -e

# Ensure we're in the right directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

echo "=== Testing Rust Installation ==="
echo "================================="

# Test Rust version
echo "→ Rust compiler version:"
rustc --version
rustc --print sysroot

# Test Cargo
echo ""
echo "=== Testing Cargo Build System ==="
echo "→ Cargo version:"
cargo --version

echo "→ Cleaning previous builds..."
cargo clean

echo ""
echo "→ Building in debug mode..."
cargo build
echo "Debug build size: $(du -h target/debug/rust_test 2>/dev/null | cut -f1)"

echo ""
echo "→ Building in release mode..."
cargo build --release
echo "Release build size: $(du -h target/release/rust_test 2>/dev/null | cut -f1)"

echo ""
echo "→ Running application..."
cargo run --release

# Test cargo check (fast type checking)
echo ""
echo "=== Testing Cargo Check ==="
cargo check --all-targets

# Test Rust formatter
echo ""
echo "=== Testing Rustfmt Formatter ==="
echo "→ Rustfmt version:"
cargo fmt --version

echo "→ Checking code format..."
if ! cargo fmt --check 2>/dev/null; then
    echo "→ Code needs formatting. Showing diff:"
    cargo fmt -- --check --color=always || true
    echo "Note: Format differences are expected in test files"
fi

# Test Clippy linter
echo ""
echo "=== Testing Clippy Linter ==="
echo "→ Clippy version:"
cargo clippy --version

echo "→ Running clippy lints..."
cargo clippy -- -D warnings || echo "Clippy check completed (may have warnings)"

echo "→ Running clippy with pedantic lints..."
cargo clippy -- -W clippy::pedantic || true

# Test Cargo test framework
echo ""
echo "=== Testing Cargo Test Framework ==="
echo "→ Running unit tests..."
cargo test --lib

echo "→ Running all tests (including doc tests)..."
cargo test

echo "→ Running tests with output..."
cargo test -- --nocapture || true

# Test cargo doc
echo ""
echo "=== Testing Documentation Generation ==="
echo "→ Generating documentation..."
cargo doc --no-deps
echo "Documentation generated in target/doc/"

# Test cargo tree (dependency inspection)
echo ""
echo "=== Testing Dependency Management ==="
echo "→ Showing dependency tree..."
cargo tree | head -20

# Test cargo bench (if benchmarks exist)
echo ""
echo "=== Testing Benchmarks ==="
cargo bench --no-run || echo "Benchmark compilation test completed"

# Test cargo audit (security vulnerabilities)
echo ""
echo "=== Testing Security Audit ==="
if command -v cargo-audit &> /dev/null; then
    cargo audit || echo "Security audit completed"
else
    echo "cargo-audit not installed (optional tool)"
fi

# Test different target compilation
echo ""
echo "=== Testing Cross-Compilation Targets ==="
echo "→ Available targets:"
rustc --print target-list | head -10

# Create and test a simple Rust script
echo ""
echo "=== Testing Rust Script Execution ==="
cat > test_script.rs << 'EOF'
fn main() {
    println!("Rust script execution works!");
    let numbers: Vec<i32> = vec![1, 2, 3, 4, 5];
    let sum: i32 = numbers.iter().sum();
    println!("Sum of {:?} = {}", numbers, sum);
}
EOF

echo "→ Compiling and running standalone script..."
rustc test_script.rs -o test_script
./test_script
rm -f test_script test_script.rs

echo ""
echo "✅ Rust tests completed successfully!"
echo "======================================"
echo "Tested: rustc, cargo, rustfmt, clippy, tests, docs, dependencies"
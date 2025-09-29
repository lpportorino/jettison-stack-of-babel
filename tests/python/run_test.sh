#!/bin/bash
# Python Test Runner - Comprehensive Testing
# Tests: Python, pip, formatters (black), linters (flake8, ruff), type checking (mypy), compilation (Nuitka)

set -e

echo "=== Testing Python Installation ==="
echo "==================================="

# Test Python version
echo "→ Python version:"
python3 --version
python3 -c "import sys; print(f'Python {sys.version}')"

# Test pip
echo ""
echo "=== Testing Package Management (pip) ==="
echo "→ pip version:"
pip3 --version

echo "→ Installing dependencies..."
pip3 install -r requirements.txt

echo "→ Listing installed packages:"
pip3 list | head -20

# Run the main application
echo ""
echo "=== Running Python Application ==="
python3 src/main.py

# Test Black formatter
echo ""
echo "=== Testing Black Formatter ==="
echo "→ Black version:"
black --version

echo "→ Checking code format..."
black --check src/ || {
    echo "→ Code needs formatting. Showing diff:"
    black --diff src/
}

echo "→ Formatting code (dry-run)..."
black --diff --color src/ || true

# Test Flake8 linter
echo ""
echo "=== Testing Flake8 Linter ==="
echo "→ Flake8 version:"
flake8 --version

echo "→ Running flake8 checks..."
flake8 src/ --show-source --statistics || echo "Flake8 check completed (may have warnings)"

# Test Ruff linter (faster alternative)
echo ""
echo "=== Testing Ruff Linter ==="
echo "→ Ruff version:"
ruff --version

echo "→ Running ruff checks..."
ruff check src/ --show-fixes || echo "Ruff check completed (may have warnings)"

# Test mypy type checker
echo ""
echo "=== Testing MyPy Type Checker ==="
echo "→ MyPy version:"
mypy --version

echo "→ Running type checking..."
mypy src/main.py --show-error-codes || echo "MyPy check completed (may have type warnings)"

# Test pytest
echo ""
echo "=== Testing PyTest Framework ==="
echo "→ Creating test file..."
mkdir -p tests
cat > tests/test_sample.py << 'EOF'
def test_addition():
    assert 1 + 1 == 2

def test_string():
    assert "hello".upper() == "HELLO"
EOF

echo "→ Running pytest..."
python3 -m pytest tests/ -v || echo "PyTest completed"

# Test Nuitka compiler
echo ""
echo "=== Testing Nuitka Python-to-C++ Compiler ==="
echo "→ Nuitka version:"
python3 -m nuitka --version

echo "→ Compiling Python to standalone binary..."
python3 -m nuitka --onefile --output-dir=build --assume-yes-for-downloads src/main.py

echo "→ Running compiled binary..."
./build/main.bin

# Test Python virtual environment
echo ""
echo "=== Testing Virtual Environment (venv) ==="
echo "→ Creating virtual environment..."
python3 -m venv test_venv

echo "→ Activating and testing venv..."
source test_venv/bin/activate
python --version
pip list | head -5
deactivate

# Cleanup
rm -rf test_venv tests build

echo ""
echo "✅ Python tests completed successfully!"
echo "========================================"
echo "Tested: Python3, pip, black, flake8, ruff, mypy, pytest, Nuitka, venv"
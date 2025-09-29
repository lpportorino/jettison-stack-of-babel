#!/bin/bash
set -e
echo "=== Testing Python ==="
python3 --version
pip3 install -r requirements.txt
python3 src/main.py
black --check src/
flake8 src/ || true
ruff check src/
mypy src/main.py || true
python3 -m nuitka --onefile --output-dir=build src/main.py
./build/main.bin
echo "✓ Python tests completed!"
#!/bin/bash
# Python container version check
set -e

echo "=== Python Container Version Check ==="
echo ""
echo "Python: $(python --version)"
echo "Pip: $(pip --version)"
echo "Pyenv: $(pyenv --version)"
echo "Nuitka: $(python -m nuitka --version 2>&1 | head -n1)"
echo "Black: $(black --version)"
echo "Flake8: $(flake8 --version)"
echo "MyPy: $(mypy --version)"
echo "Ruff: $(ruff --version)"
echo "Pytest: $(pytest --version)"
echo ""
echo "PYENV_ROOT: $PYENV_ROOT"
echo "NUITKA_CACHE_DIR: $NUITKA_CACHE_DIR"
echo ""
echo "Installed Python versions:"
pyenv versions
echo ""
echo "✓ Python container ready"
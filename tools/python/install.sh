#!/bin/bash
# Python Installation via pyenv
# Supports multiple Python versions with easy switching

set -e

echo "=== Installing Python via pyenv ==="

# Install build dependencies
apt-get update
apt-get install -y \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    git

# Install pyenv
export PYENV_ROOT="/opt/pyenv"
if [ ! -d "$PYENV_ROOT" ]; then
    git clone https://github.com/pyenv/pyenv.git $PYENV_ROOT
fi

# Configure pyenv
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Create global pyenv configuration
cat > /etc/profile.d/pyenv.sh << 'EOF'
export PYENV_ROOT="/opt/pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi
EOF

# Install Python versions
PYTHON_VERSIONS=(
    "3.13.7"  # Latest stable (August 2025)
    "3.12.8"  # Previous stable
)

for version in "${PYTHON_VERSIONS[@]}"; do
    echo "Installing Python $version..."
    # Use configure options to reduce size
    CONFIGURE_OPTS="--enable-optimizations --with-lto --enable-loadable-sqlite-extensions" \
    PYTHON_CONFIGURE_OPTS="--disable-test-modules" \
    pyenv install -s $version

    # Remove test files and __pycache__ to save space
    find $PYENV_ROOT/versions/$version -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
    find $PYENV_ROOT/versions/$version -type d -name test -exec rm -rf {} + 2>/dev/null || true
    find $PYENV_ROOT/versions/$version -type d -name tests -exec rm -rf {} + 2>/dev/null || true
    rm -rf $PYENV_ROOT/versions/$version/lib/python*/test
    rm -rf $PYENV_ROOT/versions/$version/lib/python*/*/test
    rm -rf $PYENV_ROOT/versions/$version/lib/python*/*/tests
done

# Set global Python version
pyenv global 3.13.7

# Create symlinks for system-wide access
ln -sf $PYENV_ROOT/versions/3.13.7/bin/python3 /usr/local/bin/python3
ln -sf $PYENV_ROOT/versions/3.13.7/bin/pip3 /usr/local/bin/pip3
ln -sf /usr/local/bin/python3 /usr/local/bin/python
ln -sf /usr/local/bin/pip3 /usr/local/bin/pip

# Upgrade pip
pip3 install --upgrade pip setuptools wheel

echo "✓ Python installed successfully"
python3 --version
pip3 --version
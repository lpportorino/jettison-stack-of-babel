#!/bin/bash
# Web Development Tools Installation Script

set -e

echo "=== Installing Web Development Tools ==="

# Ensure Node.js is installed
if ! command -v node &> /dev/null; then
    echo "✗ Node.js not found. Please install Node.js first."
    exit 1
fi

echo "Installing esbuild..."
npm install -g esbuild@latest

echo "Installing Prettier..."
npm install -g prettier@latest

echo "Installing ESLint..."
npm install -g eslint@latest

echo "Installing @lit/localize..."
npm install -g @lit/localize@latest @lit/localize-tools@latest

echo "Installing Bun..."
# Bun installer automatically detects architecture
export BUN_INSTALL="/opt/bun"
curl -fsSL https://bun.sh/install | bash -s "bun-v1.1.45"
mv ~/.bun/* /opt/bun/ 2>/dev/null || true
rm -rf ~/.bun
export PATH="$BUN_INSTALL/bin:$PATH"

# Create environment file for Bun
cat > /etc/profile.d/bun.sh << 'EOF'
export BUN_INSTALL="/opt/bun"
export PATH="$BUN_INSTALL/bin:$PATH"
EOF

echo "✓ Web development tools installed successfully"
echo "  - esbuild: $(esbuild --version 2>&1)"
echo "  - prettier: $(prettier --version 2>&1)"
echo "  - eslint: $(eslint --version 2>&1)"
echo "  - bun: $(bun --version 2>&1 || echo 'installation may have failed')"
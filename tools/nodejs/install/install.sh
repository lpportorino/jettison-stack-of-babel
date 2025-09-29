#!/bin/bash
# Node.js 22 LTS Installation Script
# Using NodeSource repository for latest LTS version

set -e

echo "=== Installing Node.js 22 LTS ==="

# Detect architecture
ARCH=$(uname -m)
echo "Detected architecture: $ARCH"

# Install prerequisites
apt-get update
apt-get install -y curl gnupg ca-certificates

# Add NodeSource repository for Node.js 22
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -

# Install Node.js
apt-get install -y nodejs

# Enable Corepack for package manager support (yarn, pnpm)
corepack enable

# Update npm to latest
npm install -g npm@latest

# Verify installation
echo "✓ Node.js installed successfully"
node --version
npm --version

# Create environment configuration
cat > /etc/profile.d/nodejs.sh << 'EOF'
# Node.js configuration
export NODE_OPTIONS="--max-old-space-size=4096"
EOF

echo "✓ Node.js configuration complete"
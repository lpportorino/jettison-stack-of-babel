#!/bin/bash
# Package Managers Installation Script

set -e

echo "=== Installing Package Managers ==="

# Ensure Node.js is installed
if ! command -v node &> /dev/null; then
    echo "✗ Node.js not found. Please install Node.js first."
    exit 1
fi

# Enable Corepack (includes yarn and pnpm)
echo "Enabling Corepack..."
corepack enable

# Prepare latest versions
echo "Preparing yarn..."
corepack prepare yarn@stable --activate

echo "Preparing pnpm..."
corepack prepare pnpm@latest --activate

# Install alternative: direct global install (fallback)
# npm install -g yarn@latest pnpm@latest

echo "✓ Package managers installed successfully"
yarn --version
pnpm --version
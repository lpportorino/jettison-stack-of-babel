#!/bin/bash
# TypeScript Installation Script

set -e

echo "=== Installing TypeScript ==="

# Ensure Node.js is installed
if ! command -v node &> /dev/null; then
    echo "✗ Node.js not found. Please install Node.js first."
    exit 1
fi

# Install TypeScript globally
npm install -g typescript@latest

# Install TS Node for direct TypeScript execution
npm install -g ts-node@latest

# Install type definitions for Node.js
npm install -g @types/node@latest

echo "✓ TypeScript installed successfully"
tsc --version
ts-node --version
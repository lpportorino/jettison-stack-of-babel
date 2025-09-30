#!/bin/bash
set -e

# Ensure we're in the right directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

echo "=== Testing Node.js/TypeScript/npm/yarn/pnpm ==="

# Test Node.js
echo "Node.js version:"
node --version
npm --version

# Test package managers
echo "Testing package managers:"
yarn --version
pnpm --version

# Install dependencies with npm
echo "Installing dependencies with npm..."
npm install

# Test TypeScript compilation
echo "Testing TypeScript compilation..."
npx tsc --noEmit

# Test ESLint
echo "Testing ESLint..."
npx eslint src --max-warnings 5 || true

# Test Prettier
echo "Testing Prettier..."
npx prettier --check src || true

# Test building with esbuild
echo "Testing esbuild..."
npx esbuild src/index.js --bundle --platform=node --outfile=dist/bundle.js

# Run the test
echo "Running Node.js test..."
NODE_ENV=test node src/index.js

# Test with different package managers
echo "Testing yarn..."
yarn install --frozen-lockfile
yarn start

echo "Testing pnpm..."
# First run without frozen-lockfile to create lockfile if missing
if [ ! -f "pnpm-lock.yaml" ]; then
    pnpm install
else
    pnpm install --frozen-lockfile
fi
pnpm start

echo "✓ Node.js/TypeScript tests completed!"
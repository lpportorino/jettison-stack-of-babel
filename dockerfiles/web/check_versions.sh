#!/bin/bash
# Web container version check
set -e

echo "=== Web Container Version Check ==="
echo ""
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "yarn: $(yarn --version 2>/dev/null || echo 'not activated')"
echo "pnpm: $(pnpm --version 2>/dev/null || echo 'not activated')"
echo "Bun: $(bun --version)"
echo "TypeScript: $(tsc --version)"
echo "esbuild: $(esbuild --version)"
echo "Prettier: $(prettier --version)"
echo "ESLint: $(eslint --version)"
echo ""
echo "Additional tools:"
vite --version 2>/dev/null && echo "Vite: installed" || echo "Vite: not found"
tsx --version 2>/dev/null && echo "tsx: installed" || echo "tsx: not found"
echo ""
echo "BUN_INSTALL: $BUN_INSTALL"
echo ""
echo "✓ Web container ready"
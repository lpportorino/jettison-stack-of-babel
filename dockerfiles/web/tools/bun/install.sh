#!/bin/bash
# Bun Installation Script

set -e

echo "=== Installing Bun ==="

# Install prerequisites
apt-get update
apt-get install -y curl unzip

# Install Bun
export BUN_INSTALL="/opt/bun"
curl -fsSL https://bun.sh/install | bash -s "bun-v1.1.45"

# Create symlinks for system-wide access
ln -sf $BUN_INSTALL/bin/bun /usr/local/bin/bun
ln -sf $BUN_INSTALL/bin/bunx /usr/local/bin/bunx

# Add to profile
cat > /etc/profile.d/bun.sh << 'EOF'
export BUN_INSTALL="/opt/bun"
export PATH=$BUN_INSTALL/bin:$PATH
EOF

echo "✓ Bun installed successfully"
bun --version
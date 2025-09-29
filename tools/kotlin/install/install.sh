#!/bin/bash
# Kotlin Installation Script
# Using SDKMAN for version management

set -e

echo "=== Installing Kotlin ==="

# Install prerequisites
apt-get update
apt-get install -y curl zip unzip

# Install SDKMAN
export SDKMAN_DIR="/opt/sdkman"

if [ ! -d "$SDKMAN_DIR" ]; then
    curl -s "https://get.sdkman.io" | bash
fi

# Source SDKMAN
source "$SDKMAN_DIR/bin/sdkman-init.sh"

# Install Kotlin
sdk install kotlin

# Create system-wide links
ln -sf $SDKMAN_DIR/candidates/kotlin/current/bin/kotlin /usr/local/bin/kotlin
ln -sf $SDKMAN_DIR/candidates/kotlin/current/bin/kotlinc /usr/local/bin/kotlinc

# Create environment file
cat > /etc/profile.d/kotlin.sh << 'EOF'
export SDKMAN_DIR="/opt/sdkman"
[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
EOF

echo "✓ Kotlin installed successfully"
kotlin -version
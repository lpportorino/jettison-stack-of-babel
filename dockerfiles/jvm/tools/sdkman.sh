#!/bin/bash
# SDKMAN Installation Script for Docker

set -e

echo "=== Installing SDKMAN ==="

# Install prerequisites
apt-get update
apt-get install -y curl zip unzip

# Install SDKMAN
export SDKMAN_DIR="/opt/sdkman"
curl -s "https://get.sdkman.io" | bash

# Source SDKMAN
source "${SDKMAN_DIR}/bin/sdkman-init.sh"

# Install JVM tools using SDKMAN
sdk install java 25-tem
sdk install maven 3.9.11
sdk install gradle 9.1.0
sdk install kotlin 2.2.20
sdk install leiningen 2.12.0

# Create environment file for all users
cat > /etc/profile.d/sdkman.sh << 'EOF'
export SDKMAN_DIR="/opt/sdkman"
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
EOF

echo "✓ SDKMAN and JVM tools installed successfully"
sdk version
java -version
mvn --version
gradle --version
kotlin -version
lein version
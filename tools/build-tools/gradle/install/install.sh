#!/bin/bash
# Gradle Installation Script

set -e

echo "=== Installing Gradle ==="

GRADLE_VERSION="8.12"
GRADLE_URL="https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"

# Install prerequisites
apt-get update
apt-get install -y wget unzip

# Download and extract Gradle
cd /opt
wget -q "$GRADLE_URL"
unzip -q gradle-${GRADLE_VERSION}-bin.zip
rm gradle-${GRADLE_VERSION}-bin.zip

# Create symlink
ln -sf /opt/gradle-${GRADLE_VERSION} /opt/gradle

# Create environment file
cat > /etc/profile.d/gradle.sh << 'EOF'
export GRADLE_HOME=/opt/gradle
export PATH=$GRADLE_HOME/bin:$PATH
EOF

# Source the environment
export GRADLE_HOME=/opt/gradle
export PATH=$GRADLE_HOME/bin:$PATH

echo "✓ Gradle installed successfully"
gradle --version
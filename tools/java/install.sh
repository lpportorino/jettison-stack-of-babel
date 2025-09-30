#!/bin/bash
# OpenJDK 21 LTS Installation Script
# Eclipse Temurin distribution (formerly AdoptOpenJDK)

set -e

echo "=== Installing OpenJDK 21 LTS (Eclipse Temurin) ==="

# Detect architecture
ARCH=$(uname -m)
echo "Detected architecture: $ARCH"

# Install prerequisites
apt-get update
apt-get install -y wget apt-transport-https gnupg

# Add Eclipse Temurin repository
wget -qO- https://packages.adoptium.net/artifactory/api/gpg/key/public | \
    gpg --dearmor > /usr/share/keyrings/adoptium.gpg

echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb jammy main" | \
    tee /etc/apt/sources.list.d/adoptium.list

# Update package list
apt-get update

# Install OpenJDK 21
apt-get install -y temurin-21-jdk

# Set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/temurin-21-jdk-amd64
if [ "$ARCH" = "aarch64" ]; then
    export JAVA_HOME=/usr/lib/jvm/temurin-21-jdk-arm64
fi

# Update alternatives
update-alternatives --set java $(find $JAVA_HOME -name java -type f | head -1)
update-alternatives --set javac $(find $JAVA_HOME -name javac -type f | head -1)

# Create environment file
cat > /etc/profile.d/java.sh << EOF
export JAVA_HOME=$JAVA_HOME
export PATH=\$JAVA_HOME/bin:\$PATH
EOF

echo "✓ OpenJDK 21 installed successfully"
java -version
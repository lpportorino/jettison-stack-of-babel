#!/bin/bash
# Apache Maven Installation Script

set -e

echo "=== Installing Apache Maven ==="

MAVEN_VERSION="3.9.10"
MAVEN_URL="https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"

# Install prerequisites
apt-get update
apt-get install -y wget

# Download and extract Maven
cd /opt
wget -q "$MAVEN_URL"
tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz
rm apache-maven-${MAVEN_VERSION}-bin.tar.gz

# Create symlink
ln -sf /opt/apache-maven-${MAVEN_VERSION} /opt/maven

# Create environment file
cat > /etc/profile.d/maven.sh << 'EOF'
export MAVEN_HOME=/opt/maven
export M2_HOME=/opt/maven
export PATH=$MAVEN_HOME/bin:$PATH
EOF

# Source the environment
export MAVEN_HOME=/opt/maven
export PATH=$MAVEN_HOME/bin:$PATH

echo "✓ Maven installed successfully"
mvn --version
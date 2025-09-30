#!/bin/bash
# Kotlin Installation Script with Development Tools
# Using SDKMAN for version management

set -e

echo "=== Installing Kotlin and Development Tools ==="

# Install prerequisites
apt-get update
apt-get install -y curl zip unzip wget

# Install SDKMAN
export SDKMAN_DIR="/opt/sdkman"

if [ ! -d "$SDKMAN_DIR" ]; then
    curl -s "https://get.sdkman.io" | bash
fi

# Source SDKMAN
source "$SDKMAN_DIR/bin/sdkman-init.sh"

# Install Kotlin (specific version to match potatoclient)
KOTLIN_VERSION="2.2.10"
sdk install kotlin $KOTLIN_VERSION
sdk default kotlin $KOTLIN_VERSION

# Create system-wide links
ln -sf $SDKMAN_DIR/candidates/kotlin/current/bin/kotlin /usr/local/bin/kotlin
ln -sf $SDKMAN_DIR/candidates/kotlin/current/bin/kotlinc /usr/local/bin/kotlinc
ln -sf $SDKMAN_DIR/candidates/kotlin/current/bin/kotlin-dce-js /usr/local/bin/kotlin-dce-js
ln -sf $SDKMAN_DIR/candidates/kotlin/current/bin/kotlinc-js /usr/local/bin/kotlinc-js
ln -sf $SDKMAN_DIR/candidates/kotlin/current/bin/kotlinc-jvm /usr/local/bin/kotlinc-jvm

# Install ktlint (Kotlin linter and formatter)
echo "=== Installing ktlint ==="
KTLINT_VERSION="1.5.0"
curl -sL "https://github.com/pinterest/ktlint/releases/download/${KTLINT_VERSION}/ktlint" -o /usr/local/bin/ktlint
chmod +x /usr/local/bin/ktlint

# Install detekt (Kotlin static code analysis)
echo "=== Installing detekt ==="
DETEKT_VERSION="1.23.7"
curl -sL "https://github.com/detekt/detekt/releases/download/v${DETEKT_VERSION}/detekt-cli-${DETEKT_VERSION}.zip" -o detekt.zip
unzip -q detekt.zip -d /opt/detekt
ln -sf /opt/detekt/detekt-cli-${DETEKT_VERSION}/bin/detekt-cli /usr/local/bin/detekt
chmod +x /usr/local/bin/detekt
rm detekt.zip

# Create sample detekt config
cat > /opt/detekt/detekt.yml << 'EOF'
# Default detekt configuration
build:
  maxIssues: 0
  weights:
    complexity: 2
    LongParameterList: 1
    style: 1
    comments: 1

processors:
  active: true

console-reports:
  active: true

output-reports:
  active: true
EOF

# Create environment file
cat > /etc/profile.d/kotlin.sh << 'EOF'
export SDKMAN_DIR="/opt/sdkman"
[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
export DETEKT_CONFIG="/opt/detekt/detekt.yml"
EOF

echo "✓ Kotlin and development tools installed successfully"
echo "  - Kotlin version: $(kotlin -version 2>&1 | head -1)"
echo "  - kotlinc version: $(kotlinc -version 2>&1)"
echo "  - ktlint version: $(ktlint --version)"
echo "  - detekt version: $(detekt --version 2>&1 | head -1)"
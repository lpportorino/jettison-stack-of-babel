#!/bin/bash
# Clojure & Leiningen Installation Script

set -e

echo "=== Installing Clojure and Leiningen ==="

# Install prerequisites
apt-get update
apt-get install -y curl wget rlwrap

# Install Clojure CLI tools
CLOJURE_VERSION="1.12.0.1479"
curl -L -O https://github.com/clojure/brew-install/releases/download/${CLOJURE_VERSION}/linux-install.sh
chmod +x linux-install.sh
./linux-install.sh
rm linux-install.sh

# Install Leiningen
LEIN_BIN="/usr/local/bin/lein"
wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein -O $LEIN_BIN
chmod +x $LEIN_BIN

# Initialize Leiningen (downloads dependencies)
export LEIN_ROOT=true
lein version

# Create environment file
cat > /etc/profile.d/clojure.sh << 'EOF'
# Clojure configuration
alias clj='rlwrap clojure'
export LEIN_ROOT=true
EOF

echo "✓ Clojure and Leiningen installed successfully"
clojure --version
lein version
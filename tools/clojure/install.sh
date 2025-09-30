#!/bin/bash
# Clojure CLI tools and clj-kondo Installation Script

set -e

echo "=== Installing Clojure CLI tools and clj-kondo ==="

# Install prerequisites
apt-get update
apt-get install -y curl rlwrap

# Install Clojure CLI tools
echo "Installing Clojure CLI tools..."
curl -L -O https://github.com/clojure/brew-install/releases/latest/download/linux-install.sh
chmod +x linux-install.sh
./linux-install.sh
rm linux-install.sh

# Install clj-kondo
echo "Installing clj-kondo..."
curl -sLO https://raw.githubusercontent.com/clj-kondo/clj-kondo/master/script/install-clj-kondo
chmod +x install-clj-kondo
./install-clj-kondo
rm install-clj-kondo

# Move clj-kondo to system path if needed
if [ -f clj-kondo ] && [ ! -f /usr/local/bin/clj-kondo ]; then
    mv clj-kondo /usr/local/bin/
fi

echo "✓ Clojure CLI tools and clj-kondo installed successfully"
clojure --version
clj-kondo --version
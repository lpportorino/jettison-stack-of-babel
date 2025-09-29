#!/bin/bash
# Clojure, Leiningen, and Tools Installation Script

set -e

echo "=== Installing Clojure, Leiningen, and Development Tools ==="

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

# Install clj-kondo (linter)
echo "=== Installing clj-kondo ==="
CLJ_KONDO_VERSION="2025.07.28"
curl -sL "https://github.com/clj-kondo/clj-kondo/releases/download/v${CLJ_KONDO_VERSION}/clj-kondo-${CLJ_KONDO_VERSION}-linux-amd64.zip" -o clj-kondo.zip
unzip -q clj-kondo.zip -d /tmp
mv /tmp/clj-kondo /usr/local/bin/
chmod +x /usr/local/bin/clj-kondo
rm clj-kondo.zip

# Install Babashka (useful for scripting)
echo "=== Installing Babashka ==="
curl -sL https://raw.githubusercontent.com/babashka/babashka/master/install | bash -s -- --dir /usr/local/bin

# Create deps.edn for global tools
mkdir -p ~/.clojure
cat > ~/.clojure/deps.edn << 'EOF'
{:aliases
 {:format {:extra-deps {dev.weavejester/cljfmt {:mvn/version "0.13.1"}}
           :main-opts ["-m" "cljfmt.main"]}
  :outdated {:extra-deps {com.github.liquidz/antq {:mvn/version "2.11.1276"}}
             :main-opts ["-m" "antq.core"]}}}
EOF

# Pre-download common tools to speed up later usage
echo "=== Pre-downloading common Clojure tools ==="
clojure -Ttools install io.github.clojure/tools.build '{:mvn/version "0.10.10"}' :as build
clojure -A:format --help 2>/dev/null || true
clojure -A:outdated --help 2>/dev/null || true

# Create environment file
cat > /etc/profile.d/clojure.sh << 'EOF'
# Clojure configuration
alias clj='rlwrap clojure'
export LEIN_ROOT=true
export CLJ_CONFIG=/root/.clojure
EOF

echo "✓ Clojure, Leiningen, and tools installed successfully"
echo "  - Clojure version: $(clojure --version 2>&1)"
echo "  - Leiningen version: $(lein version)"
echo "  - clj-kondo version: $(clj-kondo --version)"
echo "  - Babashka version: $(bb --version)"
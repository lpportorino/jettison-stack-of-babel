#!/bin/bash
# NvChad Installation Script
# Installs NvChad for the current user

set -e

CURRENT_USER=$(whoami)
HOME_DIR=$HOME

echo "=== Installing NvChad for $CURRENT_USER ==="

# Create config directory
mkdir -p "$HOME_DIR/.config"

# Clone NvChad starter
if [ -d "$HOME_DIR/.config/nvim" ]; then
    echo "Removing existing neovim config..."
    rm -rf "$HOME_DIR/.config/nvim"
fi

echo "Cloning NvChad starter..."
git clone --depth 1 https://github.com/NvChad/starter "$HOME_DIR/.config/nvim" 2>&1

# Remove .git folder as recommended
rm -rf "$HOME_DIR/.config/nvim/.git"

echo "✓ NvChad installed for $CURRENT_USER"
echo "Note: Plugins and language servers will be installed on first neovim start"

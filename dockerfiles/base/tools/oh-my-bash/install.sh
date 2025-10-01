#!/bin/bash
# Oh My Bash Installation Script
# Installs Oh My Bash for the current user with all plugins enabled

set -e

CURRENT_USER=$(whoami)
HOME_DIR=$HOME

echo "=== Installing Oh My Bash for $CURRENT_USER ==="

# Install Oh My Bash (unattended mode)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended

# Enable all plugins
if [ -f "$HOME_DIR/.bashrc" ]; then
    echo "Enabling all Oh My Bash plugins..."

    # List of all available plugins
    all_plugins="ansible asdf aws bash-preexec bashmarks battery brew bu cargo colored-man-pages chezmoi dotnet fasd fzf gcloud git goenv golang jump kubectl npm nvm progress pyenv rbenv sdkman sudo tmux-autoattach vagrant virtualenvwrapper xterm zellij-autoattach zoxide"

    # Replace the entire plugins array (handles multi-line declarations)
    # Find the line starting with "plugins=(" and replace until the closing ")"
    sed -i '/^plugins=(/,/^)/{
        /^plugins=(/ {
            c\
plugins=('"$all_plugins"')
        }
        /^)/d
        /^  /d
    }' "$HOME_DIR/.bashrc"

    echo "✓ Oh My Bash installed and configured with all plugins for $CURRENT_USER"
else
    echo "⚠ Warning: .bashrc not found"
    exit 1
fi

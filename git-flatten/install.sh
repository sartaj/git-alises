#!/bin/bash

##
## Config
##
SCRIPT_URL="https://raw.githubusercontent.com/sartaj/git-aliases/refs/heads/main/git-flatten/git-flatten.sh"
ALIAS="flatten"
DESCRIPTION="Flatten all commits into one"
INSTALL_DIR="$HOME/bin"

##
## Run
##

echo "📥 Installing $ALIAS..."

# Exit immediately if a command exits with a non-zero status
set -e

# Create install directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Download the script
SCRIPT="${SCRIPT_URL##*/}"
SCRIPT_PATH="$INSTALL_DIR/git-flatten"
curl -o "$SCRIPT_PATH" "$SCRIPT_URL"
chmod +x "$SCRIPT_PATH"

# Add to PATH if needed
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.bashrc"
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.zshrc"
fi

echo "✨ Installed git-$ALIAS to $INSTALL_DIR"
echo "Restart your terminal or run: source ~/.bashrc"
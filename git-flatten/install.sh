#!/bin/bash

##
## Config
##
SCRIPT_URL="https://raw.githubusercontent.com/sartaj/git-aliases/refs/heads/main/git-flatten/git-flatten.sh"
ALIAS="flatten"
DESCRIPTION="Flatten all commits into one based on the main remote branch"
INSTALL_DIR="$HOME/.git-aliases"

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
SCRIPT_PATH="$INSTALL_DIR/$SCRIPT"
curl -s "$SCRIPT_URL" > "$SCRIPT_PATH"
chmod +x "$SCRIPT_PATH"

# Unset the script name to avoid conflicts
git config --global --unset-all alias.$ALIAS

# Set up the Git alias
git config --global "alias.$ALIAS" "!$SCRIPT_PATH"
git config --global "alias.$ALIAS.description" "$DESCRIPTION"

echo "✅ Installed git-$ALIAS successfully"
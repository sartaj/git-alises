#!/bin/bash

##
## Config
##
SCRIPT_URL="https://raw.githubusercontent.com/sartaj/git-aliases/main/aliases/commit-to/git-commit-to.sh"
ALIAS="commit-to"
DESCRIPTION="Create a commit and immediately push it to a specific branch"
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
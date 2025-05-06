#!/bin/bash

##
## Config
##
SCRIPT_URL="https://raw.githubusercontent.com/sartaj/git-aliases/refs/heads/main/git-push-staged-to/git-push-staged-to.sh"
ALIAS="push-staged-to"
DESCRIPTION="Push staged changes to a specific branch"
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
SCRIPT_PATH="$INSTALL_DIR/$ALIAS.sh"
curl -s "$SCRIPT_URL" > "$SCRIPT_PATH"
chmod +x "$SCRIPT_PATH"
echo "📥 Script downloaded to $SCRIPT_PATH"

# Set up the Git alias
git config --global --unset-all alias.$ALIAS # Unset the script name to avoid conflicts
git config --global "alias.$ALIAS" "!$SCRIPT_PATH"
git config --global "alias.$ALIAS.description" "$DESCRIPTION"

echo "✅ Installed git-$ALIAS successfully"
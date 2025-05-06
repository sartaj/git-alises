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
SCRIPT="$ALIAS.sh"
SCRIPT_PATH="$INSTALL_DIR/$SCRIPT"
echo "🔧 Downloading script to $SCRIPT_PATH"
curl -s "$SCRIPT_URL" > "$SCRIPT_PATH"
chmod +x "$SCRIPT_PATH"

# Set up the Git alias
echo "🔧 Setting up git alias..."
# Remove any existing alias first
git config --global --unset-all "alias.${ALIAS}" || true
# Add the new alias with proper quoting
git config --global "alias.${ALIAS}" "\"!${SCRIPT_PATH}\""
git config --global "alias.${ALIAS}.description" "${DESCRIPTION}"

echo "✅ Installed git-$ALIAS successfully"
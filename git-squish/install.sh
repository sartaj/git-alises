#!/bin/bash

##
## Config
##
SCRIPT="git-squish.sh"
ALIAS="squish"
DESCRIPTION="Squash all commits on current branch back to where it diverged from base branch"
SCRIPT_URL="https://raw.githubusercontent.com/sartaj/git-alises/main/aliases/squish/git-squish.sh"

# Exit immediately if a command exits with a non-zero status
set -e

##
## Run
##

# Create .git-alises directory if it doesn't exist
INSTALL_DIR="$HOME/.git-alises"
mkdir -p "$INSTALL_DIR"

# Download the script
SCRIPT_PATH="$INSTALL_DIR/$SCRIPT"
curl -s "$SCRIPT_URL" > "$SCRIPT_PATH"
chmod +x "$SCRIPT_PATH"

# Unset the script name to avoid conflicts
git config --global --unset-all alias.$ALIAS

# Set up the Git alias
git config --global "alias.$ALIAS" "!$SCRIPT_PATH"
git config --global "alias.$ALIAS.description" "$DESCRIPTION"

echo "✅ Installed git-$ALIAS successfully"
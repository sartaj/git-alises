#!/bin/bash

# Exit immediately if a command exits with a non-zero status (i.e., if any command fails)
set -e

##
## Config
##
SCRIPT_NAME="git-commit-to.sh"
ALIAS_NAME="commit-to"
ALIAS_DESCRIPTION="Create a commit and immediately push it to a specific branch"

##
## Run
##

# Get the absolute path of the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_NAME"
chmod +x "$SCRIPT_PATH"

# Unset the script name to avoid conflicts
git config --global --unset-all alias.$ALIAS_NAME

# Set up the Git alias
git config --global "alias.$ALIAS_NAME" "!$SCRIPT_PATH"
git config --global "alias.$ALIAS_NAME.description" "$ALIAS_DESCRIPTION"
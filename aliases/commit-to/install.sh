#!/bin/bash

##
## Config
##
SCRIPT="git-commit-to.sh"
ALIAS="commit-to"
DESCRIPTION="Create a commit and immediately push it to a specific branch"

# Exit immediately if a command exits with a non-zero status (i.e., if any command fails)
set -e

##
## Run
##

# Get the absolute path of the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT"
chmod +x "$SCRIPT_PATH"

# Unset the script name to avoid conflicts
git config --global --unset-all alias.$ALIAS

# Set up the Git alias
git config --global "alias.$ALIAS" "!$SCRIPT_PATH"
git config --global "alias.$ALIAS.description" "$DESCRIPTION"
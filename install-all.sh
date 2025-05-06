#!/bin/bash

## Master installer script that runs git aliases installers directly from GitHub

##
## Config
##
ALIASES=("git-commit-to" "git-squish")

##
## Run
##

# Exit immediately if a command exits with a non-zero status
set -e

# Configuration
GITHUB_RAW_URL="https://raw.githubusercontent.com/sartaj/git-aliases/main"

echo "🌟 Installing Git aliases..."

# Run install scripts for each alias directly from GitHub
for alias in "${ALIASES[@]}"; do
    echo "📥 Installing $alias..."
    curl -s "$GITHUB_RAW_URL/$alias/install.sh" | bash
    echo "  ✅ Installation of $alias complete!"
done

echo ""
echo "🎉 Installation complete!"
echo "Run this script again at any time to update!"
echo ""
#!/bin/bash

# Master installer script for custom Git aliases
# Usage: curl -s https://raw.githubusercontent.com/sartaj/git-aliases/refs/heads/main/install.sh | bash

set -e

# Configuration
REPO_URL="https://github.com/sartaj/git-aliases.git"
INSTALL_DIR="$HOME/.sartaj-git-aliases"
CONFIG_FILE="$INSTALL_DIR/aliases.conf"

echo "🌟 Installing/Updating Git aliases..."

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed! Please install git and try again."
    exit 1
fi

# Always ensure we have the latest version
if [ -d "$INSTALL_DIR" ]; then
    echo "📂 Updating existing installation..."
    cd "$INSTALL_DIR"
    git fetch origin main
    git reset --hard origin/main
    echo "✅ Repository updated to latest version!"
else
    echo "📂 Creating installation directory..."
    echo "📥 Cloning repository..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    if [ $? -ne 0 ]; then
        echo "❌ Failed to clone repository! Aborting."
        exit 1
    fi
    echo "✅ Repository cloned successfully!"
fi

# Navigate to the installation directory
cd "$INSTALL_DIR"

# Read aliases from the configuration
echo "📖 Reading alias configuration..."
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Configuration file not found! Aborting."
    exit 1
fi

# Process each alias in the configuration
while IFS=',' read -r alias_name script_file description || [[ -n "$alias_name" ]]; do
    # Skip comments, empty lines, and configuration settings
    [[ "$alias_name" =~ ^#.* ]] && continue
    [[ -z "$alias_name" ]] && continue
    [[ "$alias_name" =~ ^@.* ]] && continue
    
    # Remove quotes from description
    description=$(echo "$description" | sed 's/^"//;s/"$//')
    
    echo "🔧 Installing alias: $alias_name ($description)"
    
    # Ensure the script file exists and is executable
    if [ ! -f "$INSTALL_DIR/aliases/$script_file" ]; then
        echo "  ❌ Script file not found: $script_file"
        continue
    fi
    
    chmod +x "$INSTALL_DIR/aliases/$script_file"
    
    # Set up the Git alias to directly use the script
    echo "  🔧 Setting up Git alias..."
    git config --global "alias.$alias_name" "!$INSTALL_DIR/aliases/$script_file"
    
    echo "  ✅ Installation of $alias_name complete!"
done < "$CONFIG_FILE"

# Final instructions
echo ""
echo "🎉 Installation complete!"
echo ""
echo "Available commands:"
while IFS=',' read -r alias_name script_file description || [[ -n "$alias_name" ]]; do
    # Skip comments, empty lines, and configuration settings
    [[ "$alias_name" =~ ^#.* ]] && continue
    [[ -z "$alias_name" ]] && continue
    [[ "$alias_name" =~ ^@.* ]] && continue
    
    # Remove quotes from description
    description=$(echo "$description" | sed 's/^"//;s/"$//')
    
    echo "  git $alias_name - $description"
done < "$CONFIG_FILE"
echo ""
echo "Run this script again at any time to update to the latest version!"
echo ""
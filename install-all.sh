#!/bin/bash

# Master installer script that just loops through the aliases directory and runs the
# install.sh script in each alias directory and runs each install.sh scripts

# Exit immediately if a command exits with a non-zero status (i.e., if any command fails)
set -e

# Configuration
export INSTALL_DIR="$HOME/.sartaj-git-aliases"

echo "🌟 Installing Git aliases..."

# Create or update installation directory
if [ ! -d "$INSTALL_DIR" ]; then
    echo "📂 Creating installation directory..."
    mkdir -p "$INSTALL_DIR"
fi

# Check if git repository exists and update it, or clone it
if [ -d "$INSTALL_DIR/.git" ]; then
    echo "🔄 Updating existing repository..."
    cd "$INSTALL_DIR"
    git fetch origin
    git reset --hard origin/main
else
    echo "📥 Cloning repository..."
    rm -rf "$INSTALL_DIR"/*
    git clone https://github.com/sartaj/git-aliases.git "$INSTALL_DIR"
fi

# Process each alias in the aliases directory
for alias_dir in "$INSTALL_DIR/aliases/"*/; do
    if [ -f "${alias_dir}install.sh" ]; then
        # Run the install script
        chmod +x "${alias_dir}install.sh"
        "${alias_dir}install.sh"
        echo "  ✅ Installation of $alias_name complete!"
    fi
done

echo ""
echo "🎉 Installation complete!"
echo "Run this script again at any time to update!"
echo ""
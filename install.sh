#!/bin/bash

# Master installer script for custom Git aliases
# Usage: curl -s https://raw.githubusercontent.com/username/git-aliases/main/install.sh | bash

set -e

# Configuration
REPO_URL="https://raw.githubusercontent.com/sartaj/git-alises/refs/heads/main"
INSTALL_DIR="$HOME/.git-aliases"
BIN_DIR="$HOME/.local/bin"
CONFIG_FILE="$INSTALL_DIR/aliases.conf"

# Create required directories
mkdir -p "$INSTALL_DIR/scripts"
mkdir -p "$BIN_DIR"

echo "🌟 Installing custom Git aliases..."

# Download the configuration file
echo "📥 Downloading configuration file..."
curl -s "$REPO_URL/aliases.conf" -o "$CONFIG_FILE"

# Read aliases from the configuration
echo "📖 Reading alias configuration..."
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Configuration file not found! Aborting."
    exit 1
fi

# Parse configuration settings
DEFAULT_BASE_BRANCH="master"
while IFS= read -r line || [[ -n "$line" ]]; do
    # Process configuration settings (lines starting with @)
    if [[ "$line" =~ ^@default_base_branch=(.+)$ ]]; then
        DEFAULT_BASE_BRANCH="${BASH_REMATCH[1]}"
        echo "⚙️ Using default base branch: $DEFAULT_BASE_BRANCH"
    fi
done < "$CONFIG_FILE"

# Export the configuration setting as an environment variable
export GIT_DEFAULT_BASE_BRANCH="$DEFAULT_BASE_BRANCH"

# Process each alias in the configuration
while IFS=',' read -r alias_name script_file description || [[ -n "$alias_name" ]]; do
    # Skip comments and empty lines
    [[ "$alias_name" =~ ^#.* ]] && continue
    [[ -z "$alias_name" ]] && continue
    
    # Remove quotes from description
    description=$(echo "$description" | sed 's/^"//;s/"$//')
    
    echo "🔧 Installing alias: $alias_name ($description)"
    
    # Download the script file
    echo "  📥 Downloading $script_file..."
    curl -s "$REPO_URL/scripts/$script_file" -o "$INSTALL_DIR/scripts/$script_file"
    chmod +x "$INSTALL_DIR/scripts/$script_file"
    
    # Create the wrapper script
    echo "  🔗 Creating wrapper script..."
    cat > "$BIN_DIR/git-$alias_name" << EOF
#!/bin/bash
# $description

# Pass the default base branch environment variable to the script
export GIT_DEFAULT_BASE_BRANCH="$DEFAULT_BASE_BRANCH"

exec "$INSTALL_DIR/scripts/$script_file" "\$@"
EOF
    chmod +x "$BIN_DIR/git-$alias_name"
    
    # Set up the Git alias
    echo "  🔧 Setting up Git alias..."
    git config --global "alias.$alias_name" "!$BIN_DIR/git-$alias_name"
    
    echo "  ✅ Installation of $alias_name complete!"
done < "$CONFIG_FILE"

# Create an update script
cat > "$INSTALL_DIR/update.sh" << EOF
#!/bin/bash
# Script to update all Git aliases
curl -s $REPO_URL/install.sh | bash
echo "✅ All Git aliases updated!"
EOF
chmod +x "$INSTALL_DIR/update.sh"

# Final instructions
echo ""
echo "🎉 Installation complete!"
echo ""
echo "Make sure $BIN_DIR is in your PATH. If not, add this line to your ~/.bashrc or ~/.zshrc:"
echo "  export PATH=\"\$PATH:$BIN_DIR\""
echo ""
echo "Available commands:"
while IFS=',' read -r alias_name script_file description || [[ -n "$alias_name" ]]; do
    # Skip comments and empty lines
    [[ "$alias_name" =~ ^#.* ]] && continue
    [[ -z "$alias_name" ]] && continue
    
    # Remove quotes from description
    description=$(echo "$description" | sed 's/^"//;s/"$//')
    
    echo "  git $alias_name - $description"
done < "$CONFIG_FILE"
echo ""
echo "To update in the future, run:"
echo "  $INSTALL_DIR/update.sh"
echo ""

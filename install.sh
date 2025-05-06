#!/bin/bash

# Master installer script for custom Git aliases
# Usage: curl -s https://raw.githubusercontent.com/sartaj/git-alises/refs/heads/main/install.sh | bash

set -e

# Configuration
REPO_URL="https://github.com/sartaj/git-alises.git"
INSTALL_DIR="$HOME/.sartaj-git-alises"
BIN_DIR="$HOME/.local/bin"
CONFIG_FILE="$INSTALL_DIR/aliases.conf"

echo "🌟 Installing custom Git aliases..."

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed! Please install git and try again."
    exit 1
fi

# Create bin directory if it doesn't exist
mkdir -p "$BIN_DIR"

# Check if the installation directory already exists
if [ -d "$INSTALL_DIR" ]; then
    echo "📂 Installation directory already exists."
    echo "🔄 Updating from repository..."
    cd "$INSTALL_DIR"
    git pull origin main
    echo "✅ Update completed!"
else
    echo "📂 Creating installation directory..."
    # Clone the repository
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
    # Skip comments, empty lines, and configuration settings
    [[ "$alias_name" =~ ^#.* ]] && continue
    [[ -z "$alias_name" ]] && continue
    [[ "$alias_name" =~ ^@.* ]] && continue
    
    # Remove quotes from description
    description=$(echo "$description" | sed 's/^"//;s/"$//')
    
    echo "🔧 Installing alias: $alias_name ($description)"
    
    # Ensure the script file exists and is executable
    if [ ! -f "$INSTALL_DIR/scripts/$script_file" ]; then
        echo "  ❌ Script file not found: $script_file"
        continue
    fi
    
    chmod +x "$INSTALL_DIR/scripts/$script_file"
    
    # Create the wrapper script
    echo "  🔗 Creating wrapper script..."
    cat > "$BIN_DIR/git-$alias_name" << WRAPPER
#!/bin/bash
# $description

# Pass the default base branch environment variable to the script
export GIT_DEFAULT_BASE_BRANCH="$DEFAULT_BASE_BRANCH"

exec "$INSTALL_DIR/scripts/$script_file" "\$@"
WRAPPER
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
cd "$INSTALL_DIR"
git pull origin main
$INSTALL_DIR/install.sh
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
    # Skip comments, empty lines, and configuration settings
    [[ "$alias_name" =~ ^#.* ]] && continue
    [[ -z "$alias_name" ]] && continue
    [[ "$alias_name" =~ ^@.* ]] && continue
    
    # Remove quotes from description
    description=$(echo "$description" | sed 's/^"//;s/"$//')
    
    echo "  git $alias_name - $description"
done < "$CONFIG_FILE"
echo ""
echo "To update in the future, run:"
echo "  $INSTALL_DIR/update.sh"
echo ""
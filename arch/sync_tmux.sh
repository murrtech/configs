#!/bin/bash

# Define paths
TMUX_CONFIG="$HOME/.tmux"
SOURCE_CONFIG="$HOME/Documents/compass/configs/tmux"
PLUGIN_SOURCE="$SOURCE_CONFIG/plugins"

# Check if source directory exists
if [ ! -d "$SOURCE_CONFIG" ]; then
    echo "Error: Source config directory '$SOURCE_CONFIG' not found"
    exit 1
fi

# Create tmux config directory if it doesn't exist
rm -rf "$TMUX_CONFIG"
mkdir -p "$TMUX_CONFIG/plugins"

# Copy all configuration files except .git directories
echo "Installing tmux configuration files..."
cp -r "$SOURCE_CONFIG/." "$TMUX_CONFIG/" 2>/dev/null

# Copy plugins from local repository, excluding .git directories
echo "Installing plugins from local repository..."
for plugin in "$PLUGIN_SOURCE"/*; do
    if [ -d "$plugin" ]; then
        plugin_name=$(basename "$plugin")
        mkdir -p "$TMUX_CONFIG/plugins/$plugin_name"
        
        # Copy files excluding .git directory
        find "$plugin" -type f -not -path "*/\.git/*" -exec cp --parents {} "$TMUX_CONFIG/plugins/$plugin_name/" \;
        find "$plugin" -type d -not -path "*/\.git/*" -exec mkdir -p "$TMUX_CONFIG/plugins/$plugin_name/{}" \;
    fi
done

# Set proper permissions
chown -R $USER:$USER "$TMUX_CONFIG"
find "$TMUX_CONFIG" -type f -exec chmod 644 {} \;
find "$TMUX_CONFIG" -type d -exec chmod 755 {} \;
find "$TMUX_CONFIG" -name "*.sh" -exec chmod +x {} \;

# Make plugin scripts executable
find "$TMUX_CONFIG/plugins" -type f -name "*.sh" -exec chmod +x {} \;
find "$TMUX_CONFIG/plugins" -type f -path "*/bin/*" -exec chmod +x {} \;

# Check if the main config file exists
if [ -f "$SOURCE_CONFIG/.tmux.conf" ]; then
    # Create symlink to ~/.tmux.conf
    ln -sf "$TMUX_CONFIG/.tmux.conf" "$HOME/.tmux.conf"
    
    echo "New tmux configuration has been installed successfully!"
    
    # Check if tmux is running
    if [ -n "$TMUX" ]; then
        echo "Sourcing new configuration..."
        tmux source-file "$HOME/.tmux.conf"
        echo "Configuration has been applied!"
    else
        echo "No tmux session detected. Start tmux to use the new configuration."
    fi
else
    echo "Error: Failed to find .tmux.conf in the configuration directory"
    exit 1
fi
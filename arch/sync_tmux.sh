#!/bin/bash

# Define paths
TMUX_CONFIG="$HOME/.tmux"
SOURCE_CONFIG="$HOME/Documents/compass/configs/tmux"
TPM_PATH="$TMUX_CONFIG/plugins/tpm"

# Check if source directory exists
if [ ! -d "$SOURCE_CONFIG" ]; then
    echo "Error: Source config directory '$SOURCE_CONFIG' not found"
    exit 1
fi

# Create tmux config directory if it doesn't exist
rm -rf "$TMUX_CONFIG"
mkdir -p "$TMUX_CONFIG"

# Copy all files from source directory
echo "Installing tmux configuration files..."
cp -r "$SOURCE_CONFIG/." "$TMUX_CONFIG/"

# Install TPM if not present
if [ ! -d "$TPM_PATH" ]; then
    echo "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"
fi

# Set proper permissions
chown -R $USER:$USER "$TMUX_CONFIG"
find "$TMUX_CONFIG" -type f -exec chmod 644 {} \;
find "$TMUX_CONFIG" -type d -exec chmod 755 {} \;
find "$TMUX_CONFIG" -name "*.sh" -exec chmod +x {} \;
chmod +x "$TPM_PATH/tpm"
chmod +x "$TPM_PATH/scripts/install_plugins.sh"
chmod +x "$TPM_PATH/scripts/update_plugin.sh"
chmod +x "$TPM_PATH/scripts/clean_plugins.sh"
chmod +x "$TPM_PATH/bin/install_plugins"
chmod +x "$TPM_PATH/bin/clean_plugins"
chmod +x "$TPM_PATH/bin/update_plugins"

# Check if the main config file exists
if [ -f "$SOURCE_CONFIG/.tmux.conf" ]; then
    # Create symlink to ~/.tmux.conf if it doesn't exist
    ln -sf "$TMUX_CONFIG/.tmux.conf" "$HOME/.tmux.conf"
    
    echo "New tmux configuration has been installed successfully!"
    
    # Check if tmux is running
    if [ -n "$TMUX" ]; then
        echo "Sourcing new configuration..."
        tmux source-file "$HOME/.tmux.conf"
        # Install plugins
        echo "Installing tmux plugins..."
        "$TPM_PATH/bin/install_plugins"
        echo "Configuration has been applied!"
    else
        echo "No tmux session detected. Start tmux and press prefix + I to install plugins."
    fi
else
    echo "Error: Failed to find .tmux.conf in the configuration directory"
    exit 1
fi
#!/bin/bash
# Exit on any error
set -e

# Define paths
TMUX_CONFIG="$HOME/.tmux"
SOURCE_CONFIG="$HOME/Documents/compass/configs/tmux"

# Check if gitmux is installed
if ! command -v gitmux &> /dev/null; then
    echo "Installing gitmux..."
    yay -S gitmux
else
    echo "gitmux already installed, skipping..."
fi

# Create fresh tmux config directory
echo "Creating config directory..."
rm -rf "$TMUX_CONFIG"
mkdir -p "$TMUX_CONFIG"

# Copy all configuration files
echo "Installing configuration files..."
cp -r "$SOURCE_CONFIG/." "$TMUX_CONFIG/"

# Create symlink
ln -sf "$TMUX_CONFIG/.tmux.conf" "$HOME/.tmux.conf"

# Install TPM if not already present
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Source tmux config and install plugins
tmux source ~/.tmux.conf
~/.tmux/plugins/tpm/bin/install_plugins

echo "Done! Configuration and plugins installed.  
    prefix + I  - install. 
    prefix + Ctrl-s - save
    prefix + Ctrl-r - restore
"
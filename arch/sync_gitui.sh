#!/bin/bash

# Define paths
GITUI_CONFIG="$HOME/.config/gitui"
SOURCE_CONFIG="$HOME/Documents/compass/configs/gitui"
CONFIG_FILE="theme.ron"

# Check if source config file exists
if [ ! -f "$SOURCE_CONFIG/$CONFIG_FILE" ]; then
    echo "Error: Source config file '$SOURCE_CONFIG/$CONFIG_FILE' not found"
    exit 1
fi

# Create gitui config directory if it doesn't exist
mkdir -p "$GITUI_CONFIG"

# Copy only the config file
echo "Installing gitui theme..."
cp "$SOURCE_CONFIG/$CONFIG_FILE" "$GITUI_CONFIG/$CONFIG_FILE"

# Set proper permissions
chown $USER:$USER "$GITUI_CONFIG/$CONFIG_FILE"
chmod 644 "$GITUI_CONFIG/$CONFIG_FILE"

echo "GitUI theme has been installed successfully!"
#!/bin/bash

# Define paths
FISH_CONFIG="$HOME/.config/fish"
SOURCE_CONFIG="$HOME/Documents/compass/configs/fish"
CONFIG_FILE="config.fish"

# Check if source config file exists
if [ ! -f "$SOURCE_CONFIG/$CONFIG_FILE" ]; then
    echo "Error: Source config file '$SOURCE_CONFIG/$CONFIG_FILE' not found"
    exit 1
fi

# Create fish config directory if it doesn't exist
mkdir -p "$FISH_CONFIG"

# Copy only the config file
echo "Installing fish configuration file..."
cp "$SOURCE_CONFIG/$CONFIG_FILE" "$FISH_CONFIG/$CONFIG_FILE"

# Set proper permissions
chown $USER:$USER "$FISH_CONFIG/$CONFIG_FILE"
chmod 644 "$FISH_CONFIG/$CONFIG_FILE"

# Reload fish configuration if we're in fish
if [ "$SHELL" = "/usr/bin/fish" ]; then
    echo "Reloading fish configuration..."
    fish -c "source $FISH_CONFIG/$CONFIG_FILE"
    echo "Configuration has been applied!"
else
    echo "Not currently in fish shell. Start fish to use the new configuration."
fi
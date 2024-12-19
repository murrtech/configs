#!/bin/bash

# Define paths
ALACRITTY_CONFIG="$HOME/.config/alacritty"
SOURCE_CONFIG="$HOME/Documents/compass/configs/alacritty"
CONFIG_FILE="alacritty.toml"

# Check if source config file exists
if [ ! -f "$SOURCE_CONFIG/$CONFIG_FILE" ]; then
    echo "Error: Source config file '$SOURCE_CONFIG/$CONFIG_FILE' not found"
    exit 1
fi

# Create alacritty config directory if it doesn't exist
mkdir -p "$ALACRITTY_CONFIG"

# Copy only the config file
echo "Installing alacritty configuration file..."
cp "$SOURCE_CONFIG/$CONFIG_FILE" "$ALACRITTY_CONFIG/$CONFIG_FILE"

# Set proper permissions
chown $USER:$USER "$ALACRITTY_CONFIG/$CONFIG_FILE"
chmod 644 "$ALACRITTY_CONFIG/$CONFIG_FILE"

echo "Alacritty configuration has been installed successfully!"
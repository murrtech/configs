#!/bin/bash

# Define paths
NEWSBOAT_CONFIG_DIR="$HOME/.newsboat"
SOURCE_CONFIG_DIR="$HOME/Documents/compass/configs/newsboat"
CONFIG_FILES=("config" "urls")

# Check if source directory exists
if [ ! -d "$SOURCE_CONFIG_DIR" ]; then
    echo "Error: Source directory '$SOURCE_CONFIG_DIR' not found"
    exit 1
fi

# Create newsboat config directory if it doesn't exist
mkdir -p "$NEWSBOAT_CONFIG_DIR"

# Copy each config file
for file in "${CONFIG_FILES[@]}"; do
    if [ ! -f "$SOURCE_CONFIG_DIR/$file" ]; then
        echo "Warning: Source file '$SOURCE_CONFIG_DIR/$file' not found, skipping..."
        continue
    fi
    
    echo "Installing newsboat $file..."
    cp "$SOURCE_CONFIG_DIR/$file" "$NEWSBOAT_CONFIG_DIR/$file"
    
    # Set proper permissions
    chown $USER:$USER "$NEWSBOAT_CONFIG_DIR/$file"
    chmod 644 "$NEWSBOAT_CONFIG_DIR/$file"
    
    echo "Installed $file successfully!"
done

echo "Newsboat configuration has been synced successfully!"
#!/bin/bash

# Define source and target paths
CONFIG_PATH=~/Documents/compass/configs/mutt
TARGET_PATH=~/.config/

# Create the target directory if it doesn't exist
mkdir -p "$TARGET_PATH"

# Copy all files and directories from the source to the target location
for item in "$CONFIG_PATH"*; do
    cp -r "$item" "$TARGET_PATH"
done

# Reset the terminal screen
reset

echo "MUTT configuration files have been copied to $TARGET_PATH."

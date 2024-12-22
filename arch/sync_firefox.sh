#!/bin/bash

# Define paths
SOURCE_CONFIG="$HOME/Documents/compass/configs/firefox"
CONFIG_FILE="userChrome.css"
FIREFOX_PROFILE=$(find ~/.mozilla/firefox -maxdepth 1 -type d -name "*default-release")
CHROME_DIR="$FIREFOX_PROFILE/chrome"

# Check if Firefox profile exists
if [ -z "$FIREFOX_PROFILE" ]; then
    echo "Error: Firefox profile not found"
    exit 1
fi

# Check if source config file exists
if [ ! -f "$SOURCE_CONFIG/$CONFIG_FILE" ]; then
    echo "Error: Source config file '$SOURCE_CONFIG/$CONFIG_FILE' not found"
    exit 1
fi

# Create chrome directory if it doesn't exist
mkdir -p "$CHROME_DIR"

# Copy the CSS file
echo "Installing Firefox CSS configuration..."
cp "$SOURCE_CONFIG/$CONFIG_FILE" "$CHROME_DIR/$CONFIG_FILE"

# Set proper permissions
chown $USER:$USER "$CHROME_DIR/$CONFIG_FILE"
chmod 644 "$CHROME_DIR/$CONFIG_FILE"

# Enable custom CSS in Firefox
prefs_file="$FIREFOX_PROFILE/prefs.js"
if [ -f "$prefs_file" ]; then
    if ! grep -q "toolkit.legacyUserProfileCustomizations.stylesheets" "$prefs_file"; then
        echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$prefs_file"
        echo "Enabled custom CSS support in Firefox"
    fi
else
    echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' > "$prefs_file"
    echo "Created preferences file and enabled custom CSS support"
fi

# Check if Firefox is running
if pgrep firefox > /dev/null; then
    echo "Note: Firefox is currently running. Please restart Firefox to apply changes."
else
    echo "Configuration has been installed. Start Firefox to apply changes."
fi
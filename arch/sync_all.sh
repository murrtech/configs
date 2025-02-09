#!/bin/bash

# Get the fixed config directory path regardless of where script is run from
CONFIG_DIR="/home/Documents/compass/configs/arch"

# Check if directory exists
if [ ! -d "$CONFIG_DIR" ]; then
   echo "Error: Config directory not found at $CONFIG_DIR"
   exit 1
fi

echo "Beginning all syncs from $CONFIG_DIR"
cd "$CONFIG_DIR" || {
   echo "Error: Could not change to config directory"
   exit 1
}

for script in sync_{alacritty,firefox,fish,gitui,newsboat,nvim,tmux}.sh; do
   if [ -f "$script" ]; then
       echo -e "\nRunning $script..."
       # Get absolute path
       script_path="$CONFIG_DIR/$script"
       # Make executable
       chmod +x "$script_path"
       # Run script
       bash "$script_path"
       if [ $? -eq 0 ]; then
           echo "✓ Completed $script successfully"
       else
           echo "✗ Failed $script"
       fi
   else
       echo "Warning: $script not found in $CONFIG_DIR"
   fi
done

echo -e "\nSync Summary:"
echo "-------------"
for script in sync_{alacritty,firefox,fish,gitui,newsboat,nvim,tmux}.sh; do
   if [ -f "$script" ]; then
       echo "✓ $script"
   else
       echo "✗ $script missing"
   fi
done
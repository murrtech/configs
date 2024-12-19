#!/bin/bash

# Define paths
PLUGIN_TARGET="$HOME/Documents/compass/configs/tmux/plugins"
mkdir -p "$PLUGIN_TARGET"

# Define plugin repositories
declare -A plugins=(
    ["tpm"]="https://github.com/tmux-plugins/tpm.git"
    ["tmux-yank"]="https://github.com/tmux-plugins/tmux-yank.git"
    ["tmux-better-mouse-mode"]="https://github.com/nhdaly/tmux-better-mouse-mode.git"
    ["tmux-menus"]="https://github.com/jaclu/tmux-menus.git"
    ["tmux-gitbar"]="https://github.com/aurelien-rainone/tmux-gitbar.git"
    ["tmux-mem-cpu-load"]="https://github.com/thewtex/tmux-mem-cpu-load.git"
    ["tmux-sidebar"]="https://github.com/tmux-plugins/tmux-sidebar.git"
    ["tmux-autoreload"]="https://github.com/b0o/tmux-autoreload.git"
)

# Update or clone each plugin
for plugin in "${!plugins[@]}"; do
    plugin_path="$PLUGIN_TARGET/$plugin"
    if [ -d "$plugin_path" ]; then
        echo "Updating $plugin..."
        git -C "$plugin_path" pull
    else
        echo "Cloning $plugin..."
        git clone "${plugins[$plugin]}" "$plugin_path"
    fi
done

echo "All plugins have been updated!"
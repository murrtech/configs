#!/bin/bash

# Execute all sync scripts
for script in sync_{alacritty,firefox,fish,gitui,newsboat,nvim,tmux}.sh; do
   if [ -f "$script" ]; then
       echo "Running $script..."
       bash "$script"
   fi
done


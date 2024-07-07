#!/bin/bash
set -x

TIMESTAMP=$(date +%s)
SESSION="${1:-WorkSession-$TIMESTAMP}"
COMPASS="$HOME/Documents/compass/"
COMPASS_SERVICES="$HOME/Documents/compass-services/"

tmux new-session -d -s "$SESSION"

# TERMINALS SESSION
tmux rename-window -t 0 'tmux'
tmux send-keys -t "$SESSION":0.0 "htop" C-m
tmux split-window -t "$SESSION":0 -v -c "${COMPASS}"
tmux send-keys -t "$SESSION":0.1 "ls" C-m
tmux resize-pane -t "$SESSION":0.0 -y 12%
tmux split-window -t "$SESSION":0.1 -h -c "${COMPASS_SERVICES}"
tmux send-keys -t "$SESSION":0.2 "ls" C-m

# Select the main window
tmux select-window -t "$SESSION":0

set +x

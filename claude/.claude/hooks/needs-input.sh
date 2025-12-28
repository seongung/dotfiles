#!/bin/bash

if [[ -n "$TMUX" ]]; then
    SESSION=$(tmux display-message -t "$TMUX_PANE" -p '#S')
    WINDOW=$(tmux display-message -t "$TMUX_PANE" -p '#W')
    tmux display-popup -d "#{pane_current_path}" -w 45 -h 3 \
        "echo '⏳ Claude needs input in  $SESSION:$WINDOW' && read"
fi

# Different sound - Ping for attention
afplay /System/Library/Sounds/Ping.aiff &

exit 0

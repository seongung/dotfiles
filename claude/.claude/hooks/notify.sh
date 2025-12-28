#!/bin/bash

if [[ -n "$TMUX" ]]; then
    SESSION=$(tmux display-message -t "$TMUX_PANE" -p '#S')
    WINDOW=$(tmux display-message -t "$TMUX_PANE" -p '#W')
    # Bottom notification, auto-dismiss after 5 seconds
    tmux display-message -d 5000 "✓  $SESSION:$WINDOW done"
fi

afplay /System/Library/Sounds/Glass.aiff &

exit 0

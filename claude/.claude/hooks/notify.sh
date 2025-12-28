#!/bin/bash

if [[ -n "$TMUX" ]]; then
    # Skip if user is in the same pane
    CLAUDE_PANE="$TMUX_PANE"
    ACTIVE_PANE=$(tmux display-message -p '#{pane_id}')
    if [[ "$CLAUDE_PANE" == "$ACTIVE_PANE" ]]; then
        exit 0
    fi

    SESSION=$(tmux display-message -t "$TMUX_PANE" -p '#S')
    WINDOW=$(tmux display-message -t "$TMUX_PANE" -p '#W')
    tmux display-message -d 5000 "✓ Claude done • $SESSION:$WINDOW"
fi

afplay /System/Library/Sounds/Glass.aiff &

exit 0

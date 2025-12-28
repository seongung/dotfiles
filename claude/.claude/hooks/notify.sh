#!/bin/bash

# Read JSON input from stdin
INPUT=$(cat)

if [[ -n "$TMUX" ]]; then
    # Get the pane where Claude is running
    CLAUDE_PANE="$TMUX_PANE"

    # Get the currently active pane
    ACTIVE_PANE=$(tmux display-message -p '#{pane_id}')

    # Skip if user is already looking at this pane
    if [[ "$CLAUDE_PANE" == "$ACTIVE_PANE" ]]; then
        exit 0
    fi

    SESSION=$(tmux display-message -t "$TMUX_PANE" -p '#S')
    WINDOW=$(tmux display-message -t "$TMUX_PANE" -p '#W')

    # Check transcript for question (waiting for response)
    TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')
    WAITING=false
    if [[ -n "$TRANSCRIPT_PATH" && -f "$TRANSCRIPT_PATH" ]]; then
        # Get last assistant message, check if ends with ?
        LAST_MSG=$(tail -20 "$TRANSCRIPT_PATH" | grep -o '"type":"assistant"' | tail -1)
        if [[ -n "$LAST_MSG" ]]; then
            # Simple heuristic: check if transcript ends with question mark
            LAST_LINE=$(tail -1 "$TRANSCRIPT_PATH")
            if echo "$LAST_LINE" | grep -q '\?'; then
                WAITING=true
            fi
        fi
    fi

    if [[ "$WAITING" == "true" ]]; then
        tmux display-message -d 5000 "? Claude waiting •  $SESSION:$WINDOW"
    else
        tmux display-message -d 5000 "✓ Claude done •  $SESSION:$WINDOW"
    fi
fi

afplay /System/Library/Sounds/Glass.aiff &

exit 0

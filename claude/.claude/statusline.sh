#!/bin/bash
# Custom Claude Code statusline - excludes version number
input=$(cat)

# Extract values using jq
CURRENT_DIR=$(echo "$input" | jq -r '.cwd // empty')
HOOKS=$(echo "$input" | jq -r '.hooks // empty')

# Get directory basename
DIR_NAME="${CURRENT_DIR##*/}"

# Git branch if in a git repo
GIT_BRANCH=""
if [ -n "$CURRENT_DIR" ] && [ -d "$CURRENT_DIR/.git" ] || git -C "$CURRENT_DIR" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git -C "$CURRENT_DIR" branch --show-current 2>/dev/null)
    [ -n "$BRANCH" ] && GIT_BRANCH="$BRANCH | "
fi

# Hooks indicator
HOOKS_INDICATOR=""
[ -n "$HOOKS" ] && [ "$HOOKS" != "null" ] && HOOKS_INDICATOR=" hooks"

# Output: branch | icon hooks | directory
echo ""

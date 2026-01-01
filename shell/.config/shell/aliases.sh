# Shell aliases

# Navigation
alias ..="cd .."
alias ...="cd ../.."

# List files
if command -v eza &>/dev/null; then
    alias ls="eza --icons"
    alias ll="eza -la --icons"
    alias lt="eza -la --tree --level=2 --icons"
else
    alias ls="ls --color=auto"
    alias ll="ls -la"
fi

# Git shortcuts
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline -15"
alias gd="git diff"

# Editor
alias v="nvim"
alias vim="nvim"

# Safety
alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"

# Tmux
alias t="tmux"
alias ta="tmux attach -t"
alias tn="tmux new -s"
alias tl="tmux list-sessions"

# Dotfiles
alias dotfiles="cd ~/.dotfiles"
alias reload="source ~/.bashrc 2>/dev/null || source ~/.zshrc 2>/dev/null"

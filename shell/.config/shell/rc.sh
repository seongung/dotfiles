# Main shell configuration
# Sourced by .bashrc/.zshrc

SHELL_CONFIG_DIR="${HOME}/.config/shell"

# Source environment
[ -f "${SHELL_CONFIG_DIR}/env.sh" ] && source "${SHELL_CONFIG_DIR}/env.sh"

# Source aliases
[ -f "${SHELL_CONFIG_DIR}/aliases.sh" ] && source "${SHELL_CONFIG_DIR}/aliases.sh"

# Initialize starship prompt
if command -v starship &>/dev/null; then
    eval "$(starship init bash 2>/dev/null || starship init zsh 2>/dev/null)"
fi

# Initialize zoxide if available
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash 2>/dev/null || zoxide init zsh 2>/dev/null)"
fi

# Initialize atuin if available
if command -v atuin &>/dev/null; then
    eval "$(atuin init bash 2>/dev/null || atuin init zsh 2>/dev/null)"
fi

# FZF integration
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

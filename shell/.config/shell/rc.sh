# Main shell configuration
# Sourced by .bashrc/.zshrc

SHELL_CONFIG_DIR="${HOME}/.config/shell"

# Source environment
[ -f "${SHELL_CONFIG_DIR}/env.sh" ] && source "${SHELL_CONFIG_DIR}/env.sh"

# Source aliases
[ -f "${SHELL_CONFIG_DIR}/aliases.sh" ] && source "${SHELL_CONFIG_DIR}/aliases.sh"

# Detect current shell
if [ -n "$ZSH_VERSION" ]; then
    CURRENT_SHELL="zsh"
elif [ -n "$BASH_VERSION" ]; then
    CURRENT_SHELL="bash"
else
    CURRENT_SHELL="bash"
fi

# Initialize starship prompt
if command -v starship &>/dev/null; then
    eval "$(starship init $CURRENT_SHELL)"
fi

# Initialize zoxide if available
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init $CURRENT_SHELL)"
fi

# Initialize atuin if available
if command -v atuin &>/dev/null; then
    eval "$(atuin init $CURRENT_SHELL)"
fi

# FZF integration
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

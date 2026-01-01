#!/usr/bin/env bash
#
# Dotfiles Installer
# Usage: curl -sL https://raw.githubusercontent.com/seongung/dotfiles/master/install.sh | bash
#
# Environment variables:
#   DOTFILES_REMOTE=1    - Force remote mode (use remote tmux config)
#   DOTFILES_BACKUP=0    - Skip backup of existing configs
#   DOTFILES_MINIMAL=1   - Skip optional tools installation
#

set -euo pipefail

# Configuration
REPO_URL="https://github.com/seongung/dotfiles.git"
DOTFILES_DIR="${HOME}/.dotfiles"
BACKUP_DIR="${HOME}/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Detect if running on remote server
detect_remote() {
    if [[ -n "${SSH_CONNECTION:-}" ]] || [[ -n "${SSH_TTY:-}" ]] || [[ "${DOTFILES_REMOTE:-0}" == "1" ]]; then
        return 0
    fi
    return 1
}

# Check prerequisites
check_prereqs() {
    local missing=()
    command -v git >/dev/null || missing+=("git")

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing[*]}"
        exit 1
    fi
}

# Backup existing config
backup_existing() {
    local paths=(
        "${HOME}/.config/tmux"
        "${HOME}/.config/nvim"
        "${HOME}/.config/starship.toml"
        "${HOME}/.config/shell"
    )

    local needs_backup=false
    for path in "${paths[@]}"; do
        if [[ -e "$path" ]] && [[ ! -L "$path" ]]; then
            needs_backup=true
            break
        fi
    done

    if $needs_backup && [[ "${DOTFILES_BACKUP:-1}" == "1" ]]; then
        log_info "Backing up existing configs to $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        for path in "${paths[@]}"; do
            if [[ -e "$path" ]] && [[ ! -L "$path" ]]; then
                mv "$path" "$BACKUP_DIR/" 2>/dev/null || true
            fi
        done
    fi
}

# Clone or update dotfiles repo
clone_repo() {
    if [[ -d "$DOTFILES_DIR" ]]; then
        log_info "Updating existing dotfiles..."
        git -C "$DOTFILES_DIR" pull --ff-only || log_warn "Could not update, using existing"
    else
        log_info "Cloning dotfiles repository..."
        git clone --depth 1 "$REPO_URL" "$DOTFILES_DIR"
    fi
}

# Create symlink with parent directory creation
symlink() {
    local src="$1"
    local dest="$2"

    # Create parent directory
    mkdir -p "$(dirname "$dest")"

    # Remove existing symlink or file
    if [[ -L "$dest" ]]; then
        rm "$dest"
    elif [[ -e "$dest" ]]; then
        mv "$dest" "${BACKUP_DIR}/" 2>/dev/null || rm -rf "$dest"
    fi

    ln -s "$src" "$dest"
    log_info "Linked: $dest"
}

# Setup tmux
setup_tmux() {
    local is_remote="$1"

    mkdir -p "${HOME}/.config/tmux"

    if [[ "$is_remote" == "true" ]]; then
        log_info "Setting up tmux (remote mode)..."
        symlink "${DOTFILES_DIR}/tmux/.config/tmux/remote/tmux.conf" "${HOME}/.config/tmux/tmux.conf"
        symlink "${DOTFILES_DIR}/tmux/.config/tmux/remote/statusline.conf" "${HOME}/.config/tmux/statusline.conf"
    else
        log_info "Setting up tmux (local mode)..."
        # Remove directory first if it exists
        rm -rf "${HOME}/.config/tmux"
        symlink "${DOTFILES_DIR}/tmux/.config/tmux" "${HOME}/.config/tmux"
    fi
}

# Setup neovim
setup_nvim() {
    log_info "Setting up neovim..."
    symlink "${DOTFILES_DIR}/nvim/.config/nvim" "${HOME}/.config/nvim"
}

# Setup starship
setup_starship() {
    log_info "Setting up starship..."
    symlink "${DOTFILES_DIR}/starship/.config/starship.toml" "${HOME}/.config/starship.toml"

    # Install starship if not present
    if ! command -v starship >/dev/null; then
        log_info "Installing starship to ~/.local/bin..."
        mkdir -p "${HOME}/.local/bin"
        curl -sS https://starship.rs/install.sh | sh -s -- -y -b "${HOME}/.local/bin"
    fi
}

# Setup shell configuration
setup_shell() {
    log_info "Setting up shell config..."
    symlink "${DOTFILES_DIR}/shell/.config/shell" "${HOME}/.config/shell"

    # Add source line to shell rc files
    local source_line='[ -f "$HOME/.config/shell/rc.sh" ] && source "$HOME/.config/shell/rc.sh"'

    for rc in "${HOME}/.bashrc" "${HOME}/.zshrc"; do
        if [[ -f "$rc" ]]; then
            if ! grep -q '.config/shell/rc.sh' "$rc"; then
                log_info "Adding source line to $rc"
                echo "" >> "$rc"
                echo "# Dotfiles shell config" >> "$rc"
                echo "$source_line" >> "$rc"
            fi
        fi
    done
}

# Install optional tools
install_optional_tools() {
    if [[ "${DOTFILES_MINIMAL:-0}" == "1" ]]; then
        log_info "Skipping optional tools (minimal mode)"
        return
    fi

    # fzf
    if ! command -v fzf >/dev/null && [[ ! -d "${HOME}/.fzf" ]]; then
        log_info "Installing fzf..."
        git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
        "${HOME}/.fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-zsh
    fi
}

# Main installation
main() {
    log_info "Starting dotfiles installation..."

    check_prereqs

    local is_remote="false"
    if detect_remote; then
        is_remote="true"
        log_info "Detected REMOTE environment"
    else
        log_info "Detected LOCAL environment"
    fi

    # Create backup directory in case we need it
    mkdir -p "$BACKUP_DIR"

    backup_existing
    clone_repo

    setup_tmux "$is_remote"
    setup_nvim
    setup_starship
    setup_shell

    if [[ "$is_remote" == "false" ]]; then
        install_optional_tools
    fi

    # Cleanup empty backup dir
    rmdir "$BACKUP_DIR" 2>/dev/null || true

    log_info "Installation complete!"
    log_info "Restart your shell or run: source ~/.bashrc (or ~/.zshrc)"
}

main "$@"

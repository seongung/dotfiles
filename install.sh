#!/usr/bin/env bash
#
# Dotfiles Installer
# Usage: curl -sL https://raw.githubusercontent.com/seongung/dotfiles/master/install.sh | bash
# NOTE: Must use bash, not sh (script uses bash-specific features)
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

# Ask user for environment type
ask_environment() {
    # Check for explicit override first
    if [[ "${DOTFILES_REMOTE:-}" == "1" ]]; then
        echo "remote"
        return
    elif [[ "${DOTFILES_REMOTE:-}" == "0" ]]; then
        echo "local"
        return
    fi

    # Interactive prompt (read from /dev/tty for curl|bash compatibility)
    echo -e "${YELLOW}Is this a local machine or remote server?${NC}" >&2
    echo "  1) Local (full config with plugins)" >&2
    echo "  2) Remote (minimal config)" >&2
    read -p "Enter choice [1/2]: " choice </dev/tty
    case "$choice" in
        2|r|R|remote) echo "remote" ;;
        *) echo "local" ;;
    esac
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
        local starship_arch
        case "$(uname -m)" in
            x86_64) starship_arch="x86_64" ;;
            aarch64|arm64) starship_arch="aarch64" ;;
            *) log_warn "Unsupported architecture for starship"; return ;;
        esac
        case "$(uname -s)" in
            Linux)  curl -sL "https://github.com/starship/starship/releases/latest/download/starship-${starship_arch}-unknown-linux-musl.tar.gz" | tar xz -C "${HOME}/.local/bin" ;;
            Darwin) curl -sL "https://github.com/starship/starship/releases/latest/download/starship-${starship_arch}-apple-darwin.tar.gz" | tar xz -C "${HOME}/.local/bin" ;;
        esac
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

# Install CLI tools (both local and remote)
install_tools() {
    if [[ "${DOTFILES_MINIMAL:-0}" == "1" ]]; then
        log_info "Skipping tools (minimal mode)"
        return
    fi

    mkdir -p "${HOME}/.local/bin"

    local arch os
    case "$(uname -m)" in
        x86_64)  arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
        *) log_warn "Unsupported architecture"; return ;;
    esac
    case "$(uname -s)" in
        Linux)  os="linux" ;;
        Darwin) os="darwin" ;;
        *) log_warn "Unsupported OS"; return ;;
    esac

    # yq (YAML processor)
    if ! command -v yq >/dev/null; then
        log_info "Installing yq..."
        curl -sL "https://github.com/mikefarah/yq/releases/latest/download/yq_${os}_${arch}" -o "${HOME}/.local/bin/yq"
        chmod +x "${HOME}/.local/bin/yq"
    fi

    # fzf (fuzzy finder)
    if ! command -v fzf >/dev/null && [[ ! -d "${HOME}/.fzf" ]]; then
        log_info "Installing fzf..."
        git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
        "${HOME}/.fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-zsh
    fi

    # zoxide (smarter cd)
    if ! command -v zoxide >/dev/null; then
        log_info "Installing zoxide..."
        local zoxide_arch="${arch}"
        [[ "$arch" == "amd64" ]] && zoxide_arch="x86_64"
        [[ "$arch" == "arm64" ]] && zoxide_arch="aarch64"
        # Get latest version (v0.9.8 -> 0.9.8)
        local zoxide_ver=$(curl -sL "https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest" | grep '"tag_name"' | cut -d'"' -f4 | tr -d 'v')
        if [[ -n "$zoxide_ver" ]]; then
            if [[ "$os" == "linux" ]]; then
                curl -sL "https://github.com/ajeetdsouza/zoxide/releases/download/v${zoxide_ver}/zoxide-${zoxide_ver}-${zoxide_arch}-unknown-linux-musl.tar.gz" | tar xz -C "${HOME}/.local/bin" zoxide
            elif [[ "$os" == "darwin" ]]; then
                curl -sL "https://github.com/ajeetdsouza/zoxide/releases/download/v${zoxide_ver}/zoxide-${zoxide_ver}-${zoxide_arch}-apple-darwin.tar.gz" | tar xz -C "${HOME}/.local/bin" zoxide
            fi
        fi
    fi

    # dust (disk usage)
    if ! command -v dust >/dev/null; then
        log_info "Installing dust..."
        local dust_arch="${arch}"
        [[ "$arch" == "amd64" ]] && dust_arch="x86_64"
        [[ "$arch" == "arm64" ]] && dust_arch="aarch64"
        if [[ "$os" == "linux" ]]; then
            # Get latest version from GitHub API
            local dust_ver=$(curl -sL "https://api.github.com/repos/bootandy/dust/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
            if [[ -n "$dust_ver" ]]; then
                curl -sL "https://github.com/bootandy/dust/releases/download/${dust_ver}/dust-${dust_ver}-${dust_arch}-unknown-linux-musl.tar.gz" | tar xz -C /tmp
                mv /tmp/dust-*/dust "${HOME}/.local/bin/" 2>/dev/null
                rm -rf /tmp/dust-*
            fi
        elif [[ "$os" == "darwin" ]] && command -v brew >/dev/null; then
            brew install dust
        fi
    fi

    # btop (system monitor) - Linux only, use Homebrew on macOS
    if ! command -v btop >/dev/null; then
        if [[ "$os" == "linux" ]]; then
            log_info "Installing btop..."
            local btop_arch="${arch}"
            [[ "$arch" == "amd64" ]] && btop_arch="x86_64"
            [[ "$arch" == "arm64" ]] && btop_arch="aarch64"
            curl -sL "https://github.com/aristocratos/btop/releases/latest/download/btop-${btop_arch}-unknown-linux-musl.tbz" -o /tmp/btop.tbz
            if [[ -f /tmp/btop.tbz ]] && file /tmp/btop.tbz | grep -q bzip2; then
                tar -xjf /tmp/btop.tbz -C /tmp
                mv /tmp/btop/bin/btop "${HOME}/.local/bin/"
                rm -rf /tmp/btop*
            fi
        elif [[ "$os" == "darwin" ]] && command -v brew >/dev/null; then
            log_info "Installing btop via Homebrew..."
            brew install btop
        fi
    fi

    # atuin (shell history)
    if ! command -v atuin >/dev/null; then
        log_info "Installing atuin..."
        curl -sL https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh | ATUIN_NO_MODIFY_PATH=1 sh -s -- --no-modify-path
    fi
}

# Main installation
main() {
    log_info "Starting dotfiles installation..."

    check_prereqs

    local env_type
    env_type=$(ask_environment)
    local is_remote="false"
    if [[ "$env_type" == "remote" ]]; then
        is_remote="true"
        log_info "Setting up REMOTE environment"
    else
        log_info "Setting up LOCAL environment"
    fi

    # Create backup directory in case we need it
    mkdir -p "$BACKUP_DIR"

    backup_existing
    clone_repo

    setup_tmux "$is_remote"
    setup_nvim
    setup_starship
    setup_shell
    install_tools

    # Cleanup empty backup dir
    rmdir "$BACKUP_DIR" 2>/dev/null || true

    log_info "Installation complete!"
    log_info "Restart your shell or run: source ~/.bashrc (or ~/.zshrc)"
}

main "$@"

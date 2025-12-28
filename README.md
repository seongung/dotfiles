# Dotfiles

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Contents

- **nvim** - Neovim (LazyVim-based)
- **tmux** - Terminal multiplexer
- **ghostty** - Terminal emulator
- **starship** - Shell prompt

## Installation

### Prerequisites

```bash
# macOS
brew install stow

# Debian/Ubuntu
apt install stow
```

### Setup

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow nvim ghostty starship tmux
```

This creates symlinks in `~/.config/` pointing to the dotfiles repo.

### Uninstall

```bash
cd ~/dotfiles
stow -D nvim ghostty starship tmux
```

## Post-install

- **tmux**: Run `prefix + I` to install plugins via tpm
- **nvim**: Plugins install automatically on first launch via lazy.nvim

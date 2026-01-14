# Dotfiles

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Contents

- **nvim** - Neovim (LazyVim-based)
- **tmux** - Terminal multiplexer
- **ghostty** - Terminal emulator
- **starship** - Shell prompt
- **claude** - Claude Code config/hooks

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

# Optional
stow claude
```

This creates symlinks in `~/.config/` pointing to the dotfiles repo. (`stow` targets the parent directory of the repo by default, so cloning to `~/dotfiles` is recommended. If you clone elsewhere, use `stow -t "$HOME" ...`.)

If `stow` reports `existing target is not owned by stow`, you already have files (or symlinks from another dotfiles directory) in the target location — remove/backup them or run `stow -D ...` from the old dotfiles repo first.

### Uninstall

```bash
cd ~/dotfiles
stow -D nvim ghostty starship tmux
```

## Post-install

- **tmux**: Run `prefix + I` to install plugins via tpm
- **nvim**: Plugins install automatically on first launch via lazy.nvim

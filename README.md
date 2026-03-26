# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages

| Package | Config | Description |
|---------|--------|-------------|
| `zsh` | `.zshrc`, `.zsh_aliases` | oh-my-zsh (agnoster), eza aliases, fzf, zoxide, nvm, cargo |
| `git` | `.gitconfig` | User config, SSH URL rewrite, credential helpers |
| `tmux` | `.tmux.conf` | Mouse support, TPM plugins, alt+arrow pane switching |
| `ghostty` | `.config/ghostty/config` | Font, padding, shell override |
| `fzf` | `.fzfrc` | Default opts, fd integration |

## Install

```bash
git clone git@github.com:AdamGardelov/dotfiles.git ~/Dev/dotfiles
cd ~/Dev/dotfiles
bash install.sh
```

The install script will:
- Install `stow` if missing
- Optionally install missing tools (eza, fzf, tmux, zoxide)
- Install zsh-autosuggestions plugin
- Back up any conflicting files (`.bak`)
- Symlink all packages to `$HOME`

## Usage

```bash
# Stow a single package
stow -v --target="$HOME" zsh

# Remove a package's symlinks
stow -D --target="$HOME" zsh
```

## Secrets

API tokens and connection strings live in `~/.secrets` (sourced by `.zshrc`, not tracked by git).

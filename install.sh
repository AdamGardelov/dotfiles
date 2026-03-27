#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
PACKAGES=(zsh git tmux ghostty fzf)

green() { printf '\033[0;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
red() { printf '\033[0;31m%s\033[0m\n' "$*"; }

# Ensure essential tools are present
for tool in stow curl; do
  if ! command -v "$tool" &>/dev/null; then
    echo "$tool not found. Installing..."
    sudo apt-get update && sudo apt-get install -y "$tool"
  fi
done

# Optionally install missing tools
read -rp "Install missing tools via apt (eza, fzf, tmux, zoxide)? [y/N] " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  sudo apt-get update
  sudo apt-get install -y eza fzf tmux zoxide 2>/dev/null || true
fi

# Install oh-my-zsh if missing
if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
  green "Installing oh-my-zsh..."
  rm -rf "$HOME/.oh-my-zsh"
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install Docker Engine if missing
if ! command -v docker &>/dev/null; then
  green "Installing Docker Engine..."
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo usermod -aG docker "$USER"
  yellow "Log out and back in for docker group membership to take effect"
fi

# Install lazydocker if missing
if ! command -v lazydocker &>/dev/null; then
  green "Installing lazydocker..."
  curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
fi

# Install zsh-autosuggestions if missing
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  green "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# Back up and stow each package
cd "$DOTFILES"
for pkg in "${PACKAGES[@]}"; do
  if [ ! -d "$pkg" ]; then
    yellow "Skipping $pkg (directory not found)"
    continue
  fi

  # Back up conflicting files before stowing
  conflicts=$(stow -n -v --target="$HOME" "$pkg" 2>&1 | grep "existing target" | awk '{print $NF}' || true)
  for file in $conflicts; do
    target="$HOME/$file"
    if [ -f "$target" ] && [ ! -L "$target" ]; then
      yellow "Backing up $target -> ${target}.bak"
      mv "$target" "${target}.bak"
    fi
  done

  green "Stowing $pkg..."
  stow -v --target="$HOME" "$pkg"
done

green "Done! Restart your shell or run: source ~/.zshrc"

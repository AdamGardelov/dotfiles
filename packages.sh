#!/usr/bin/env bash
set -euo pipefail

green() { printf '\033[0;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }

# --- APT packages ---
APT_PACKAGES=(
  # Shell & terminal
  zsh
  tmux
  stow
  ghostty

  # CLI tools
  eza
  fzf
  jq
  zoxide
  curl
  wget
  xclip

  # Dev tools
  build-essential
  git
  gh
  nodejs
  npm
  python3-venv
  mono-devel

  # .NET
  dotnet-sdk-8.0
  dotnet-sdk-9.0
  aspnetcore-runtime-8.0
  aspnetcore-runtime-9.0

  # Docker
  docker-ce
  docker-ce-cli
  docker-buildx-plugin
  docker-compose-plugin

  # Networking & VPN
  openssh-server
  tailscale
  wireguard

  # Desktop & utilities
  gnome-tweaks
  gnome-shell-extension-manager
  gnome-shell-pomodoro
  flatpak
  v4l-utils
  ffmpeg
  pass
  passwordsafe

  # Azure
  azure-cli

  # API client
  bruno
)

# --- Snap packages ---
SNAP_PACKAGES=(
  code
  brave
  discord
  rider
  dbeaver-ce
  postman
  powershell
  notesnook
  todoist
  pinta
  onlyoffice-desktopeditors
)

SNAP_CLASSIC=(
  code
  rider
  powershell
)

# --- Flatpak packages ---
FLATPAK_PACKAGES=(
  app.zen_browser.zen
)

# --- Install ---
read -rp "Install APT packages? [y/N] " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
  green "Installing APT packages..."
  sudo apt-get update
  sudo apt-get install -y "${APT_PACKAGES[@]}"
fi

read -rp "Install Snap packages? [y/N] " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
  green "Installing Snap packages..."
  for pkg in "${SNAP_PACKAGES[@]}"; do
    if printf '%s\n' "${SNAP_CLASSIC[@]}" | grep -qx "$pkg"; then
      sudo snap install "$pkg" --classic 2>/dev/null || yellow "Skipped $pkg"
    else
      sudo snap install "$pkg" 2>/dev/null || yellow "Skipped $pkg"
    fi
  done
fi

read -rp "Install Flatpak packages? [y/N] " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
  green "Installing Flatpak packages..."
  for pkg in "${FLATPAK_PACKAGES[@]}"; do
    flatpak install -y flathub "$pkg" 2>/dev/null || yellow "Skipped $pkg"
  done
fi

green "Done!"
